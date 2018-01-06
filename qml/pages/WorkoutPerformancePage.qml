/*
  Schwarzenmaker.
  Copyright (C) 2015 Thomas Eigel
  Contact: Thomas Eigel <yurumi@gmx.de>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Page {
    id: root
    
    property int currentWid: -1
    property string currentWTitle: ""
    property int activeEntry: -1
    property int entryDurationMs: 0
    property int entryElapsedTimeMs: 0
    property string mainState: mainwindow.state
    
    onStatusChanged: {
        if(status === PageStatus.Deactivating){
            viewHelper.hideOverlay()
            // viewHelper.closeOverlay()
        }
    }

    function buildEntriesModel(workout_name){
        entriesModel.clear();

        var db = Storage.getDatabase();
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM " + workout_name + " ORDER BY iid;");
            for(var i = 0; i < rs.rows.length; i++) {
                var dbItem = rs.rows.item(i);
                entriesModel.append({"iid": dbItem.iid, "title": dbItem.title, "type": dbItem.type, "duration": dbItem.duration * 1000, "description": dbItem.description});
            }
        });
    }

    function proceed(){
        activeEntry += 1;

        if(activeEntry < entriesModel.count){
            proceedAnimation.start()        
        }else{
            pageStack.pop()
            viewHelper.hideOverlay()
            // viewHelper.closeOverlay()
        }
    }

    Component.onCompleted: {
        buildEntriesModel("workout_" + root.currentWid);
        audibleTimer.volume = Storage.getSetting("AudibleTimerVolume")
        initTimer.start();
    }

    onMainStateChanged: {
        if(mainState === "Play"){
            entryTimer.start()
        }else if(mainState === "Proceed"){
            root.proceed()
            mainwindow.state = "Play"
        }else if(mainState === "Pause"){
            entryTimer.stop()
        }      
    }
    
    SequentialAnimation {
        id: pauseAnimation
        running: false
        loops: Animation.Infinite
        alwaysRunToEnd: true
        NumberAnimation { target: entryDuration; property: "opacity"; to: 0.5; duration: 500 }
        NumberAnimation { target: entryDuration; property: "opacity"; to: 1.0; duration: 500 }
    }
    
    SequentialAnimation {
        id: proceedAnimation
        running: false

        NumberAnimation { target: upcomingEntryTitleRect; property: "opacity"; to: 0.0; duration: 50 }
        ParallelAnimation {
            NumberAnimation { target: entryTitle; property: "opacity"; to: 0.0; duration: 100 }
            NumberAnimation { target: entryDescription; property: "opacity"; to: 0.0; duration: 100 }
            NumberAnimation { target: progressCircle; property: "value"; to: 1.0; duration: 200 }
        }
        ScriptAction {
            script: {
                // current exercise                
                var entry = entriesModel.get(root.activeEntry);
                entryDurationMs = entry.duration
                entryElapsedTimeMs = 0;
                if(entry.type === "pause"){
                    entryTitle.text = qsTr("Pause");
                    entryDescription.text = "";
                }else{
                    entryTitle.text = entry.title;
                    entryDescription.text = entry.description;
                }
                entryTimer.start();
                viewHelper.setCurrentExerciseTitle(entryTitle.text);
                viewHelper.setCurrentExerciseDescription(entryDescription.text);
                viewHelper.setExerciseDuration(entryDurationMs / 1000);

                // upcoming excercise
                if(activeEntry < (entriesModel.count - 1)){
                    var upcomingEntry = entriesModel.get(root.activeEntry + 1);
                    var upcomingEntryDescription = ""
                    if(upcomingEntry.type === "pause"){
                        upcomingEntryTitle.text = qsTr("Pause");                       
                    }else{
                        upcomingEntryTitle.text = upcomingEntry.title;
                        upcomingEntryDescription = upcomingEntry.description;
                    }
                }else{
                    upcomingEntryTitle.text = qsTr("FINISHED")
                }
                viewHelper.setNextExercise(upcomingEntryTitle.text);
                viewHelper.setNextExerciseDescription(upcomingEntryDescription);

                // exercise duration
                entryDuration.text = root.entryDurationMs / 1000;
                viewHelper.setRemainingExerciseTime(root.entryDurationMs / 1000)
            }
        }
        ParallelAnimation {
            NumberAnimation { target: entryTitle; property: "opacity"; to: 1.0; duration: 200 }
            NumberAnimation { target: entryDescription; property: "opacity"; to: 1.0; duration: 200 }
        }
        NumberAnimation { target: upcomingEntryTitleRect; property: "opacity"; to: 1.0; duration: 500 }
    }

    Timer {
        id: initTimer
        interval: 100; running: false; repeat: false
        onTriggered: {
            viewHelper.checkActive()
            root.proceed();
            mainwindow.state = "Play"
        }
    }

    SoundEffect {
        id: audibleTimer
        source: "qrc:/sounds/blip.wav"
    }

    ListModel {
        id: entriesModel
    }
    
    Timer {
        id: entryTimer
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(Qt.application.state == Qt.ApplicationInactive){
                viewHelper.unhideOverlay()
            }else{
                viewHelper.hideOverlay()
            }
            
            appLibrary.setBlankingMode(true)

            var remainingTimeMs = root.entryDurationMs - root.entryElapsedTimeMs;

            // update progress circle
            progressCircle.value = (1.0 - (1.0 / entryDurationMs * entryElapsedTimeMs))
            
            // switch to next exercise or pause
            if(remainingTimeMs < 0){
                root.proceed();
            }else{
                entryDuration.text = remainingTimeMs / 1000;
                viewHelper.setRemainingExerciseTime(remainingTimeMs / 1000)

                // play sound for the last few seconds
                if(remainingTimeMs <= 2000){
                    audibleTimer.play();
                }
            }

            entryElapsedTimeMs += entryTimer.interval;
        }

        onRunningChanged: running ? pauseAnimation.stop() : pauseAnimation.start() 
    }

    PageHeader {
        id: pageHeader
        title: currentWTitle
    }

    Text {
        id: entryTitle
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: progressCircleBackground.top
            bottomMargin: 80 * Theme.pixelRatio
        }
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 45 * Theme.pixelRatio; // style: Text.Sunken; styleColor: "#AAAAAA"
        // font.bold: true
    }

    Text {
        id: entryDescription
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: entryTitle.bottom
            topMargin: 5 * Theme.pixelRatio
        }
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 20 * Theme.pixelRatio; // style: Text.Sunken; styleColor: "#AAAAAA"
    }

    Item {
        id: progressCircleBackground
        width: parent.width
        height: 300 * Theme.pixelRatio
        anchors.centerIn: parent

        ProgressCircle {
            id: progressCircle
            anchors.fill: parent
            progressColor: Theme.highlightColor
            backgroundColor: Theme.highlightDimmerColor
        }
        
        Text {
            id: entryDuration
            anchors.centerIn: parent
            color: Theme.highlightColor
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 64 * Theme.pixelRatio; style: Text.Sunken; styleColor: "#AAAAAA"
        }

    }

    Rectangle {
        id: upcomingEntryTitleRect
        height: 50 * Theme.pixelRatio
        width: upcomingEntryTitle.width + nextLabel.width + 50 * Theme.pixelRatio
        x: Screen.width - width
        anchors {
            top: progressCircleBackground.bottom
            topMargin: 80 * Theme.pixelRatio
        }
        color: "transparent"

        Text {
            id: nextLabel
            anchors {
                // top: parent.top
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            color: Theme.secondaryHighlightColor
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 25 * Theme.pixelRatio
            text: qsTr("Next:")
        }
        
        Text {
            id: upcomingEntryTitle
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: Theme.paddingLarge
            }
            color: Theme.highlightColor
            horizontalAlignment: Text.AlignRight
            font.pointSize: 25 * Theme.pixelRatio
        }
    }
    
    IconButton {
        id: skipButton
        width: pauseButton.width
        height: pauseButton.height
        scale: pauseButton.scale
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }   
        icon.source: "image://theme/icon-m-next"
        onClicked: root.proceed()
    }

    IconButton {
        id: pauseButton
        width: 100 * Theme.pixelRatio
        height: 100 * Theme.pixelRatio
        scale: 2.0
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }
        icon.source: entryTimer.running ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
        onClicked: {
            (mainState === "Play") ? mainwindow.state = "Pause" : mainwindow.state = "Play"
        }
    }

}
