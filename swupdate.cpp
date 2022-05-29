#include <network_ipc.h>
#include <progress_ipc.h>
#include <fcntl.h>
#include <unistd.h>
#include <QtConcurrent/QtConcurrent>
#include <QDebug>

#include <signal.h>
#include <unistd.h>

#include "swupdate.h"

static pid_t progressPid = -1;

char buf[4096];
static int fd;
bool end_status;
static SwUpdate *wrapper;

static int readimage(char **p, int *size) {
    int ret;

    ret = read(fd, buf, sizeof(buf));
    *p = buf;
    *size = ret;

    return ret;
}

static int end(RECOVERY_STATUS status)
{
    end_status = (status == SUCCESS) ? true : false;

    return 0;
}

bool SwUpdate::update(const QString file)
{
    updateFuture = QtConcurrent::run([file]() -> bool {
        struct swupdate_request req;
        int rc;

        /* This signal needs to be ingored else we would stop the application */
        signal(SIGPIPE, [](int /*sig*/) {
            qDebug() << "Swupdate broke update pipe";
        });

        QUrl fileUrl(file);
        fd = open(fileUrl.path().toStdString().c_str(), O_RDONLY);
        if (fd < 0) {
            return false;
        }

        swupdate_prepare_req(&req);

        rc = swupdate_async_start(readimage, NULL, end, &req, sizeof(req));
        if (rc) {
            return false;
        }
        return true;
    });

    if (updateFuture.isFinished() && !updateFuture.result())
        return false;

    updateWatcher.setFuture(updateFuture);

    QObject::connect(&updateWatcher, &QFutureWatcher<bool>::finished, this, &SwUpdate::updateDone);

    return true;

}

void SwUpdate::updateDone()
{
    if (updateFuture.result())
        emit updateSucceeded();
    else
        emit updateFailed();
}

void SwUpdate::progressInfo()
{
    emit progress(progressFuture.result());

    checkProgress();
}

SwUpdate::SwUpdate() : stop(false)
{
    wrapper = this;

    checkProgress();

    QObject::connect(&progressWatcher, &QFutureWatcher<QString>::finished, this, &SwUpdate::progressInfo);
}

SwUpdate::~SwUpdate()
{
    if (progressPid > 1)
        kill(progressPid, SIGUSR1);

    this->stop = true;

    this->updateFuture.waitForFinished();
    this->progressFuture.waitForFinished();
}

static int progressFd = -1;
void SwUpdate::checkProgress()
{
    progressFuture = QtConcurrent::run([this]() -> QString {
        struct progress_msg msg;

        progressPid = gettid();
        signal(SIGUSR1, [](int /*sig*/) {
            close(progressFd); /* Closing the filehandler will make read return */
        });
        while (progressFd <= 0 && !this->stop) {
            progressFd = progress_ipc_connect(false);
            QThread::msleep(500);
        }

        if (progressFd <= 0)
            return QString();

        if (progress_ipc_receive(&progressFd, &msg) <= 0) // This is blocking, use signals to interrupt
            return QString();

        switch (msg.status) {
        case IDLE:
            return QString("{\"status\": \"idle\"}");
        case RUN:
            return QString("{\"status\": \"run\", \"progress\": ") + QString::number(msg.cur_percent) + QString("}");
        case START:
            return QString("{\"status\": \"start\", \"progress\": ") + QString::number(msg.cur_percent) + QString("}");
        case SUCCESS:
            return QString("{\"status\": \"success\"}");
        case FAILURE:
            return QString("{\"status\": \"failure\", \"info\": ") + QString(msg.info) + QString("}");
        case DOWNLOAD:
            return QString("{\"status\": \"download\", \"progress\": ") + QString::number(msg.dwl_percent) + QString("}");
        case DONE:
            return QString("{\"status\": \"done\"}");
        case SUBPROCESS:
            return QString("{\"status\": \"subprocess\", \"info\": ") + QString(msg.info) + QString("}");
        case PROGRESS:
            return QString("{\"status\": \"progress\", \"progress\": ") + QString::number(msg.cur_percent) + QString("}");
        }

        return QString();
    });

    this->progressWatcher.setFuture(this->progressFuture);
}
