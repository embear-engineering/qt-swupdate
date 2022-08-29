#include "swupdate.h"
#include "configfile.h"

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
