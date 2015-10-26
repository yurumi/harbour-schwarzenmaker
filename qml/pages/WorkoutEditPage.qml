import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/storage.js" as Storage
import "../js/env.js" as Env

Dialog {
    id: root
    property int currentWid: -1
    property string currentWTitle: ""
    property bool staging: false

    function showWorkout(workout_name){
        workoutModel.clear();

        var db = Storage.getDatabase();
        db.transaction(function(tx) {
            console.log("showWorkout SQL statement: ", "SELECT * FROM " + workout_name + " ORDER BY iid;")
            var rs = tx.executeSql("SELECT * FROM " + workout_name + " ORDER BY iid;");
            console.log("Items for workout ", workout_name, ": ", rs.rows.length)
            for(var i = 0; i < rs.rows.length; i++) {
                var dbItem = rs.rows.item(i);
                console.log("Add item to model: ", dbItem.title, " ", dbItem.type)
                workoutModel.append({"iid": dbItem.iid, "title": dbItem.title, "type": dbItem.type, "duration": dbItem.duration, "description": dbItem.description});
            }
        });
    }

    function swapItems(indexFirst, indexSecond){
        var oldIidFirst = workoutModel.get(indexFirst).iid;
        var oldIidSecond = workoutModel.get(indexSecond).iid;
        Storage.swapItemId(currentWid, oldIidFirst, oldIidSecond)
        workoutModel.setProperty(indexFirst, "iid", oldIidSecond)
        workoutModel.setProperty(indexSecond, "iid", oldIidFirst)
        workoutModel.move(indexFirst, indexSecond, 1)
    }
    
    Component.onCompleted: {
        // editing an existing workout
        if(currentWid != -1){
            console.log("EDIT EXISTING WORKOUT")
            // workoutNameTF.text = root.currentWTitle
            // showWorkout("workout_" + root.currentWid);
        }
        // creating a new workout
        else{
            console.log("CREATE NEW WORKOUT")
            staging = true;
            root.currentWid = Storage.createWorkout(-1);
        }
    }

    onStatusChanged: {
        if(status === PageStatus.Activating){
            showWorkout(Storage.getWorkoutTableNameFromId(currentWid));
        }
    }

    // user wants to save new entry data
    // onAccepted: {
    onRejected: {
        console.log("SAVE WORKOUT: ", currentWTitle, " ", currentWid)
        Storage.setWorkoutTitle(currentWid, currentWTitle)
    }

    // user has rejected editing entry data, check if there are unsaved details
    // onRejected: {
    //     if(staging){
    //         console.log("DELETE WORKOUT")
    //         Storage.deleteWorkout(root.currentWid)
    //     }else{
    //         console.log("CANCEL WORKOUT EDITING")
    //     }
    // }

    SilicaListView {
        id: itemList
        anchors.fill: parent
        model: ListModel{ id: workoutModel }
        move: Transition {
            NumberAnimation { properties: "x"; duration: 200 }
        }
        moveDisplaced: Transition {
            NumberAnimation { properties: "x"; duration: 200 }
        }

        VerticalScrollDecorator { flickable: itemList }

        header: Column {
            id: column
            width: parent.width

            DialogHeader {
                id: dlgheader
                //% "Save Workout"
                cancelText: qsTrId("save-edited-workout")
            }

            TextField {
                id: workoutNameTF
                width: parent.width
                height: 100
                text: root.currentWTitle
                //: The placeholder for the name of the currently edited / created workout
                //% "Workout name"
                placeholderText: qsTrId("workout_name_editpage")
                //: The label for the textfield in which the name of the currently edited / created workout is entered
                //% "Workout name"
                label: qsTrId("workout_name_label_editpage")

                // workaround: TextField is not accessible from root item (because it's included in the header?)
                onTextChanged: {root.currentWTitle = text}
            }
        }
        
        //     /* delegate: WorkoutItemDelegate {model: workoutModel; wid: root.currentWid} */
        delegate: ListItem {
            id: workoutItemDelegate
            width: parent.width
            menu: contextMenu
            
            // anchors {
            //     left: parent.left
            //     right: parent.right
            //     margins: Theme.paddingLarge
            // }

            property int wid: currentWid

            function edit() {
                console.log("EDIT ENTRY for WID: " + root.currentWid + " IID: " + iid + " duration: " + duration)
                pageStack.push(Qt.resolvedUrl("EntryEditPage.qml"), {"currentWid": root.currentWid,
                "currentIid": iid,
                "currentIndex": index,
                "model": workoutModel,
                "type": type,
                "edit": true,
                "title": title,
                "description": description,
                "duration": duration});
        	 }
          
        	 function remove() {
              remorseAction("Deleting", function() {
                  Storage.deleteItemFromWorkout(workoutItemDelegate.wid, iid);
                  workoutModel.remove(index);
              }, 2000)
        	 }

            onClicked: { showMenu() }
          
            Component {
             id: contextMenu
             IconContextMenu {
                 IconMenuItem {
                     text: "Edit"
                     icon.source: "image://theme/icon-m-edit"
                     onClicked: {
                         hideMenu()
                         edit()
                     }
                 }
                 IconMenuItem {
                     text: "Remove"
                     icon.source: "image://theme/icon-m-delete"
                     onClicked: {
                         hideMenu()
                         remove()
                     }
                 }
                 IconMenuItem {
                     text: "Move up"
                     icon.source: "image://theme/icon-l-up"
                     onClicked: {
                         if(index > 0) {
                             swapItems(index, index - 1);
                         }
                     }
                 }
                 IconMenuItem {
                     text: "Move down"
                     icon.source: "image://theme/icon-l-down"
                     onClicked: {
                         if(index < (workoutModel.count - 1)) {
                             swapItems(index, index + 1);
                         }
                     }
                 }
             }
            }		

            Column {
                id: delegateColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Row {
                    width: parent.width
                    Label {
                        width: parent.width - durationLBL.width
                        text: if(type === "pause"){"Pause"}else{title}
                        color: if(type === "pause"){Theme.secondaryColor}else{Theme.primaryColor}
                    }
                    Label {
                        id: durationLBL
                        width: 50
                        text: duration + "\""
                        color: if(type === "pause"){Theme.secondaryColor}else{Theme.primaryColor}
                    }
                } // Row

                Label {
                    id: descriptionLabel
                    // width: workoutItemDelegate.width / 3 * 2
                    width: parent.width
                    text: if(type === "pause"){"PPPP"}else{description}
                    font.pixelSize: Theme.fontSizeTiny
                    visible: (type === "exercise") ? true : false
                }

                // Label {
                //     id: iidLBL
                //     width: workoutItemDelegate.width
                //     text: iid
                //     color: Theme.secondaryColor
                // }
            } // Column
        } // delegate

                // // PullDownMenu {
                //     //     MenuItem {
                //         // 	text: "Workout Settings"
                //         // 	onClicked: {
                //             // 	    console.log("WORKOUT SETTINGS")
                //             // 	    pageStack.push(Env.components.editWorkoutSettingsComponent)
                //             // 	}
                //             //     }
                //             // }

                // VerticalScrollDecorator {}
                //         }
            // } 
        //}// column

        PushUpMenu {
            MenuItem {
                text: "Add Exercise"
                onClicked: {
                    console.log("ADD EXERCISE")
                    pageStack.push(Qt.resolvedUrl("EntryEditPage.qml"), {"currentWid": root.currentWid, 
                    "model": workoutModel,
                    "type": "exercise",
                    "edit": false})
                }
            }
            MenuItem {
                text: "Add Pause"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("EntryEditPage.qml"), {"currentWid": root.currentWid, 
                    "model": workoutModel,
                    "type": "pause",
                    "edit": false})
                }
            }
        }

    } // flickable
}
