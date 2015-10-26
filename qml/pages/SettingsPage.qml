import QtQuick 2.1
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Dialog {
    id: settingsPage
    
    // property Settings settings

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

        PullDownMenu {
            MenuItem {
                text: qsTr("Clear local database")
                onClicked: {
                    remorseClearDatabase.execute(qsTr("Database is going to be cleared"),
                    function() {
                        Storage.clearWorkoutDatabase();
                        // createWorkoutList();
                    }
                    )
                }
            }
        }
        
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
                height: exerciseLabel.height + 50
                anchors {
                    left: parent.left
                    right: parent.right
                }
                opacity: overlayOpacitySlider.value
                
                Rectangle {
                    id: exerciseLabel
                    height: 50
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: Theme.highlightDimmerColor

                    Label {
                        id: highlightTestLBL
                        anchors {
                            left: parent.left
                            leftMargin: 10
                            //     right: parent.right
                            top: parent.top
                        }
                        color: Theme.highlightColor
                        text: "Test Test"
                    }

                    Label {
                        anchors {
                            left: highlightTestLBL.right
                            leftMargin: 10
                            top: parent.top
                        }
                        color: Theme.secondaryHighlightColor
                        text: "Test Test"
                    }
                } // Rectangle

                Rectangle {
                    id: progressBar
                    anchors{
                        left: parent.left
                        right: parent.right
                        rightMargin: 50
                        top: exerciseLabel.bottom
                    }
                    height: overlayProgressBarThicknessSlider.value
                    color: "red"
                }
            } // Item

            ComboBox {
                id: orientationSelector
                width: parent.width
                label: "Overlay Orientation"

                menu: ContextMenu {
                    MenuItem { text: "landscape" }
                    MenuItem { text: "portrait" }
                }

                // onCurrentIndexChanged: {
                //     console.log("CIDX: ", currentIndex)
                // }
            }

            Slider {
                id: overlayOpacitySlider
                anchors {
                    left: parent.left
                    right: parent.right
                }
                // width: parent.width
                label: "Overlay Opacity"
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
                label: "Overlay Progress Bar Thickness"
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
                label: "Audible Timer Volume (needs restart)"
                minimumValue: 0.0
                maximumValue: 1.0
                stepSize: 0.1
                valueText: value
            }

        } // column
    } // flickable
}

