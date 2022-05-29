#include <QFile>
#include <QJsonDocument>
#include "configfile.h"

ConfigFile::ConfigFile(QObject *parent) :
    QObject{parent}, _version("v1.0.0"), _color("#EEEEEE")
{

}

void ConfigFile::open(QString file)
{
    QFile configFile(file);
    if (configFile.exists()) {
        configFile.open(QIODevice::ReadOnly);
        QByteArray data = configFile.readAll();

        QJsonDocument json = QJsonDocument::fromJson(data);

        _version = json["version"].toString();
        emit versionChanged();

        _color = json["color"].toString();
        emit colorChanged();
    }
}
