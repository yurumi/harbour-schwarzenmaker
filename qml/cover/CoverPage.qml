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
import Sailfish.Silica 1.0

CoverBackground {
    id: coverPage
    Label {
        id: coverEntryTitle
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: coverProgressCircleBackground.top
            bottomMargin: 25 * Theme.pixelRatio
        }

        text: {
            if(typeof pageStack.currentPage.getCoverText == "function"){
                pageStack.currentPage.getCoverText()
            }else{
                "Schwarzenmaker"
            }
        }
    }

    Item {
        id: coverProgressCircleBackground
        width: parent.width
        height: 150 * Theme.pixelRatio
        anchors.centerIn: parent
        visible: pageStack.currentPage.pageType === "WorkoutPerformance"

        ProgressCircle {
            id: coverProgressCircle
            anchors.fill: parent
            progressColor: Theme.highlightColor
            backgroundColor: Theme.highlightDimmerColor

            value: {
                if(typeof pageStack.currentPage.getCoverText == "function"){
                    pageStack.currentPage.getProgress()
                }else{
                    0.0
                }
            }
        }

        Text {
            id: coverEntryDuration
            anchors.centerIn: parent
            color: Theme.highlightColor
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 40 * Theme.pixelRatio; style: Text.Sunken; styleColor: "#AAAAAA"
            text: if(pageStack.currentPage.pageType === "WorkoutPerformance"){
                pageStack.currentPage.getRemainingTimeText()
            }else{
                ""
            }
        }

    }

    Image {
        id: coverImage
        source: "qrc:///img/arnold.png"
        asynchronous: true
        opacity: 0.5
        visible: pageStack.currentPage.pageType !== "WorkoutPerformance"
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        fillMode: Image.PreserveAspectFit
    }

    CoverActionList {
        id: coverActionListPerformance

        enabled: pageStack.currentPage.pageType === "WorkoutPerformance"

        CoverAction {
            id: coverActionPause
            iconSource: {
                mainwindow.state === "Pause" ? "image://theme/icon-cover-play" : "image://theme/icon-cover-pause"
            }
            onTriggered: {
                mainwindow.pause()
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                if(typeof pageStack.currentPage.proceed == "function"){
                    pageStack.currentPage.proceed()
                }
            }
        }

    }
}
