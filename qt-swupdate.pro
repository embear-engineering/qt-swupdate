QT += qml quick network
QT += widgets quickcontrols2

CONFIG += c++11

CONFIG += qmltypes
QML_IMPORT_NAME = SwUpdate
QML_IMPORT_MAJOR_VERSION = 1

LIBS += -lswupdate

SOURCES += main.cpp \
    configfile.cpp \
    swupdate.cpp

RESOURCES += qml.qrc

target.path = /var/$$TARGET
INSTALLS += target

HEADERS += \
    configfile.h \
    swupdate.h
