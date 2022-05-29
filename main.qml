/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt OTA Update module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/
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
