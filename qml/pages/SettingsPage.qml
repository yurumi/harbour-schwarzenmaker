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

import QtQuick 2.1
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Dialog {
    id: settingsPage

    readonly property string pageType: "Settings"

    acceptDestinationAction: PageStackAction.Pop
    canAccept: true

    function acceptSettings() {
        Storage.setSetting("AudibleTimerVolume", audibleTimerVolumeSlider.value)
        Storage.setSetting("Orientation", orientationSelector.currentIndex)
        Storage.setSetting("OverlayOpacity", overlayOpacitySlider.value)
        Storage.setSetting("OverlayProgressBarThickness", overlayProgressBarThicknessSlider.value)
    }

    Component.onCompleted: {
        audibleTimerVolumeSlider.value = Storage.getSetting("AudibleTimerVolume")
        orientationSelector.currentIndex = Storage.getSetting("Orientation")
        overlayOpacitySlider.value = Storage.getSetting("OverlayOpacity")
        overlayProgressBarThicknessSlider.value = Storage.getSetting("OverlayProgressBarThickness")
    }
    
    onAccepted: {
        acceptSettings()
    }

    RemorsePopup { id: remorseClearDatabase }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + dlgheader.height

        // PullDownMenu {
        //     MenuItem {
        //         text: qsTr("Clear local database")
        //         onClicked: {
        //             remorseClearDatabase.execute(qsTr("Database is going to be cleared"),
        //             function() {
        //                 Storage.clearWorkoutDatabase();
        //             }
        //             )
        //         }
        //     }
        // }
        
        Column
        {
            id: column
            anchors.top: parent.top
            width: parent.width

            DialogHeader
            {
                id: dlgheader
                acceptText: qsTr("Save Settings")
            }

            Item {
                id: overlayTestItem
                height: exerciseLabel.height + 50 * Theme.pixelRatio
                anchors {
                    left: parent.left
                    right: parent.right
                }
                opacity: overlayOpacitySlider.value
                
                Rectangle {
                    id: exerciseLabel
                    height: 50 * Theme.pixelRatio
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.highlightDimmerColor

                    Label {
                        id: highlightTestLBL
                        anchors {
                            left: parent.left
                            leftMargin: 10 * Theme.pixelRatio
                            top: parent.top
                        }
                        color: Theme.highlightColor
                        text: "Test Test"
                    }

                    Label {
                        anchors {
                            left: highlightTestLBL.right
                            leftMargin: 10 * Theme.pixelRatio
                            top: parent.top
                        }
                        color: Theme.secondaryHighlightColor
                        text: qsTr("Test Test")
                    }
                } // Rectangle

                Rectangle {
                    id: progressBar
                    anchors{
                        left: parent.left
                        right: parent.right
                        top: exerciseLabel.bottom
                    }
                    height: overlayProgressBarThicknessSlider.value
                    color: "red"
                }
            } // Item

            ComboBox {
                id: orientationSelector
                width: parent.width
                label: qsTr("Overlay Orientation")

                menu: ContextMenu {
                    MenuItem { text: qsTr("landscape") }
                    MenuItem { text: qsTr("portrait") }
                }
            }

            Slider {
                id: overlayOpacitySlider
                anchors {
                    left: parent.left
                    right: parent.right
                }
                label: qsTr("Overlay Opacity")
                minimumValue: 0.0
                maximumValue: 1.0
                stepSize: 0.1
                valueText: value
            }

            Slider {
                id: overlayProgressBarThicknessSlider
                anchors {
                    left: parent.left
                    right: parent.right
                }
                label: qsTr("Overlay Progress Bar Thickness")
                minimumValue: 0
                maximumValue: 30
                stepSize: 1
                valueText: value + "px"
            }

            Slider {
                id: audibleTimerVolumeSlider
                anchors {
                    left: parent.left
                    right: parent.right
                }
                label: qsTr("Audible Timer Volume (needs restart)")
                minimumValue: 0.0
                maximumValue: 1.0
                stepSize: 0.1
                valueText: value
            }

        } // column
    } // flickable
}

