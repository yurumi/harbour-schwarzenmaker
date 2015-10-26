import QtQuick 2.1
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Item {
    id: root
    
    width: Screen.width
    height: Screen.height

    state: "hide"

    property int remainingExerciseTime: msg.remainingExerciseTime
    property int exerciseDuration: msg.exerciseDuration
    property int orientation: Storage.getSetting("Orientation") // 0 = landscape, 1 = portrait
    
    states: [
    State {
        name: "show"
        PropertyChanges { target: exerciseInfoRect; y: 0 }
    },
    State {
        name: "hide"
        PropertyChanges { target: exerciseInfoRect; y: -exerciseInfoRect.height }
    }
    ]

    transitions: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuad }
    }
    
    onRemainingExerciseTimeChanged: {
        if( ((exerciseDuration - remainingExerciseTime) < 5) ){
            root.state = "show"
            exerciseTitleLBL.text = msg.currentExerciseTitle
            exerciseDescriptionLBL.text = msg.currentExerciseDescription
            nextExerciseLBL.text = "Next: " + msg.nextExercise
        }
        else if( (remainingExerciseTime < 5) ){
            root.state = "show"
            exerciseTitleLBL.text = msg.nextExercise
            exerciseDescriptionLBL.text = msg.nextExerciseDescription
            nextExerciseLBL.text = ""
        }else{
            root.state = "hide"
        }
    }

    Item {
        id: rotationItem
        anchors.centerIn: root
        width: orientation == 0 ? Screen.height : Screen.width
        height: orientation == 0 ? Screen.width : Screen.height
        rotation: orientation == 0 ? 90 : 0
        opacity: Storage.getSetting("OverlayOpacity")
        
        Rectangle {
            id: exerciseInfoRect
            x: 0
            y: 0
            height: 70
            width: parent.width
            // color: "green"
            color: Theme.highlightDimmerColor

            Label {
                id: exerciseTitleLBL
                // width: parent.width
                // height: 30
                anchors {
                    left: parent.left
                    leftMargin: 10
                    //     right: parent.right
                    top: parent.top
                }
                color: Theme.highlightColor
            }
            Label {
                id: exerciseDescriptionLBL
                // width: parent.width
                // height: 20
                anchors {
                    left: exerciseTitleLBL.right
                    leftMargin: 30
                   //     right: parent.right
                    top: exerciseTitleLBL.top
                }
                color: Theme.secondaryHighlightColor
                // font.pixelSize: 20
                // text: "Description"
            }

            Label {
                id: nextExerciseLBL
                anchors {
                    left: exerciseTitleLBL.left
                    right: parent.right
                    top: exerciseTitleLBL.bottom
                }
                color: Theme.highlightColor
                font.pixelSize: 20
            }

            // Column {
            //     anchors.fill: parent

            //     Label {
            //         id: exerciseTitleLBL
            //         width: parent.width
            //         height: 30
            //     }
            //     Label {
            //         id: exerciseDescriptionLBL
            //         width: parent.width
            //         height: 20
            //         font.pointSize: 10
            //         // text: "Description"
            //     }
            // }
        }

        Rectangle {
            id: progressBar
            color: "red"
            height: Storage.getSetting("OverlayProgressBarThickness")
            width: parent.width - (parent.width / msg.exerciseDuration * (msg.exerciseDuration - msg.remainingExerciseTime) )
            anchors{
                left: exerciseInfoRect.left
                top: exerciseInfoRect.bottom
            }

            Behavior on width {
                NumberAnimation { duration: 100 }
            }
        }
    } // rotationItem
}
