import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage
// import "../js/env.js" as Env

Page {
  id: root
  
  property string table_prefix: "workout_"

  function createWorkoutList(){
    overviewModel.clear();

    var db = Storage.getDatabase();

    var tocEntries;
    db.transaction(function(tx) {
        tocEntries = tx.executeSql("SELECT * FROM toc ORDER BY wtitle;");
    });

    for(var i = 0; i < tocEntries.rows.length; i++) {
        var dbItem = tocEntries.rows.item(i);

        var entries;
        db.transaction(function(tx) {
            var tableName = "workout_" + dbItem.wid
            entries = tx.executeSql("SELECT * FROM " + tableName + ";");
        });

        var wduration = 0
        for(var j = 0; j < entries.rows.length; j++){
            wduration += entries.rows.item(j).duration
        }
        
        overviewModel.append({"wid": dbItem.wid, "wtitle": dbItem.wtitle, "wduration": wduration});
    }

  }
  
  Component.onCompleted: {
      createWorkoutList();
  }

  onStatusChanged: {
        if(status === PageStatus.Activating){
            createWorkoutList();
        }
  }

  ListModel {
      id: overviewModel
  }

  SilicaListView {
    id: listView
    anchors.fill: parent
    //spacing: 5

    model: overviewModel
    header: PageHeader {
        //% "Workout overview"
        title: qsTrId("workouts-overview")
    }
    delegate: ListItem {
        id: workoutDelegate
        menu: contextMenu
        width: parent.width
        // anchors {
        //     left: parent.left
        //     right: parent.right
        //     margins: Theme.paddingLarge
        // }

        function edit() {
            pageStack.push(Qt.resolvedUrl("WorkoutEditPage.qml"), {"currentWid": wid, "currentWTitle": wtitle})
        }

        function remove() {
            remorseAction("Deleting", function() { 
                Storage.deleteWorkout(wid);
                listView.model.remove(index);
            })
        }

        Row{
            id: delegateRow
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            
            Label {
                // width: workoutDelegate.width - durationLBL.width
                width: delegateRow.width - durationLBL.width
                text: model.wtitle
            }
            
            Label {
                id: durationLBL
                width: 50
                horizontalAlignment: Text.AlignRight
                text: {
                    if(model.wduration >= 60){
                        var minutes = Math.floor(model.wduration / 60)
                        var seconds = model.wduration % 60
                        return (minutes + "' " + seconds + "\"")
                    }else{
                        return (model.wduration + "\"")
                    }         
                }
                // x: Theme.paddingLarge
            }
        }

        onClicked: {
            pageStack.push(Qt.resolvedUrl("WorkoutPerformancePage.qml"), {"currentWid": model.wid,
            "currentWTitle": model.wtitle})
        }

        Component {
            id: contextMenu
            ContextMenu {
                MenuItem {
                    //% "Edit"
                    text: qsTrId("edit-workout")
                    onClicked: edit()
                }
                MenuItem {
                    //% "Remove"
                    text: qsTrId("remove-workout")
                    onClicked: remove()
                }
            }
        }
    } // delegate

    PullDownMenu {
        MenuItem {
            text: qsTr("Settings")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        MenuItem {
            //% "Create workout"
            text: qsTrId("create-workout")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("WorkoutEditPage.qml"))
            }
        }
    } // PullDownMenu

    VerticalScrollDecorator {}

  } // listview

}
