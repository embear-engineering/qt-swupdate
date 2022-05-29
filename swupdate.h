#ifndef SWUPDATE_H
#define SWUPDATE_H

#include <QString>
#include <QtConcurrent/QtConcurrent>
#include <QQmlEngine>

class SwUpdate : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    SwUpdate();
    ~SwUpdate();

public slots:
    bool update(const QString file);

signals:
    void progress(QString progress);
    void updateSucceeded();
    void updateFailed();

private slots:
    void updateDone();
    void progressInfo();

private:
    QFuture<bool> updateFuture;
    QFutureWatcher<bool> updateWatcher;
    void checkProgress();
    QTimer progressTimer;

    QFuture<QString> progressFuture;
    QFutureWatcher<QString> progressWatcher;

    bool stop;
};

#endif // SWUPDATE_H
