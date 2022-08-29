import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import SwUpdate 1.0

ApplicationWindow {
    visible:true

    font.pointSize: 20
    font.bold: true
    font.family: "System"

    color: configFile.color
    ColumnLayout {
        id: topLayout
        anchors.margins: 100
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            Layout.fillWidth: true
            Label { id: headLine; text: "Software Update" }
            Label { id: currentVersion; text: "Current Version: " + configFile.version; anchors.top: headLine.bottom; anchors.margins: 50}
            Label { id: state; text: "Current State: Idle"; anchors.top: currentVersion.bottom; anchors.margins: 5 }
        }

        Rectangle {
            Layout.fillWidth: true
            ProgressBar {
                id: progressBar
                anchors.top: parent.top
                anchors.topMargin: 200
                anchors.left: parent.left
                anchors.right: parent.right
                to: 100
                value: 0
            }
            Button {
                anchors.right: parent.right
                anchors.top: progressBar.bottom
                anchors.topMargin: 10
                text: "Select Update File"
                onClicked: fileDialog.open()
            }
        }
    }


    SwUpdate {
        id: softwareUpdate
        onProgress: {
            console.log(progress);
            var _progress = JSON.parse(progress);

            if (_progress.status === "start")
                state.text = "Current State: Update Started (loading file)";
            else if (_progress.status === "progress") {
                state.text = "Current State: Update Running";
                progressBar.value = _progress.progress;
            }
            else if (_progress.status === "done")
                state.text = "Current State: Update Done";
            else if (_progress.status === "failure")
                state.text = "Current State: Update Failed (" + progress + ")";
        }
    }

    ConfigFile {
        id: configFile
        Component.onCompleted: open("/usr/share/qt-swupdate/qt-swupdate.conf")
    }

    MyFileDialog {
        x: (parent.width/2)-300
        y: parent.y + 300;
        id: fileDialog
        title: "Please choose an update file"
        currentFolder: "file:///media"
        font.pointSize: 15
        onAccepted: {
            console.log("You chose: " + fileDialog.selectedFile)
            softwareUpdate.update(fileDialog.selectedFile)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

}
