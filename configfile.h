#ifndef CONFIGFILE_H
#define CONFIGFILE_H

#include <QObject>
#include <QQmlEngine>

class ConfigFile : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(QString color READ color NOTIFY colorChanged)
public:
    explicit ConfigFile(QObject *parent = nullptr);

    QString version() const {return _version;}
    QString color() const {return _color;}

signals:
    void versionChanged();
    void colorChanged();

public slots:
    void open(QString file);

private:
    QString _version;
    QString _color;

};

#endif // CONFIGFILE_H
