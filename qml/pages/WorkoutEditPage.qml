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
import "../components"
import "../js/storage.js" as Storage

Page {
    id: root
    property variant parentPage: undefined
    property int currentWid: -1
    property string currentWTitle: ""
    property bool staging: false

    function showWorkout(workout_name){
        workoutModel.clear();

        var db = Storage.getDatabase();
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM " + workout_name + " ORDER BY iid;");

            for(var i = 0; i < rs.rows.length; i++) {
                var dbItem = rs.rows.item(i);
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
        // creating a new workout
        if(currentWid == -1){
            staging = true;
            root.currentWid = Storage.createWorkout(-1);
        }
    }

    onStatusChanged: {
        if(status === PageStatus.Activating){
            showWorkout(Storage.getWorkoutTableNameFromId(currentWid));
        }
        else if(status === PageStatus.Deactivating){
            Storage.setWorkoutTitle(currentWid, currentWTitle)
            parentPage.createWorkoutList()
        }
    }

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

        ViewPlaceholder {
            enabled: (itemList.count === 0) || (currentWTitle === "")
            text: currentWTitle === "" ? qsTr("Enter workout title.") : qsTr("Pull up to add exercise or pause.")
        }

        VerticalScrollDecorator { flickable: itemList }
        
        header: Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Edit Workout")
            }
            
            TextField {
                id: workoutNameTF
                width: parent.width
                height: 100
                text: root.currentWTitle
                placeholderText: qsTr("Workout title")
                label: qsTr("Workout title")

                // workaround: TextField is not accessible from root item (because it's included in the header?)
                onTextChanged: {root.currentWTitle = text}
            }

            Rectangle {
                id: spacerRect
                width: parent.width
                height: 50
                color: "transparent"
            }
        }

        //     /* delegate: WorkoutItemDelegate {model: workoutModel; wid: root.currentWid} */
        delegate: ListItem {
            id: workoutItemDelegate
            width: parent.width
            menu: contextMenu
            
            property int wid: currentWid

            function edit() {
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
              remorseAction(qsTr("Deleting"), function() {
                  Storage.deleteItemFromWorkout(workoutItemDelegate.wid, iid);
                  workoutModel.remove(index);
              }, 2000)
        	}

            onClicked: { edit() }
          
            Component {
                id: contextMenu
                IconContextMenu {
                    IconMenuItem {
                        text: qsTr("Edit")
                        icon.source: "image://theme/icon-m-edit"
                        onClicked: {
                            hideMenu()
                            edit()
                        }
                    }
                    IconMenuItem {
                        text: qsTr("Remove")
                        icon.source: "image://theme/icon-m-delete"
                        onClicked: {
                            hideMenu()
                            remove()
                        }
                    }
                    IconMenuItem {
                        text: qsTr("Move up")
                        icon.source: "image://theme/icon-l-up"
                        onClicked: {
                            if(index > 0) {
                                swapItems(index, index - 1);
                            }
                        }
                    }
                    IconMenuItem {
                        text: qsTr("Move down")
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
                        text: if(type === "pause"){qsTr("Pause")}else{title}
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

        PushUpMenu {
            visible: root.currentWTitle.length > 0
            MenuItem {
                text: qsTr("Add exercise")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("EntryEditPage.qml"), {"currentWid": root.currentWid, 
                    "model": workoutModel,
                    "type": "exercise",
                    "edit": false})
                }
            }
            MenuItem {
                text: qsTr("Add pause")
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
