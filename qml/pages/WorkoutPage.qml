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
            // console.log("GET ENTRIES FOR ", dbItem.wtitle)
            entries = tx.executeSql("SELECT * FROM workout_" + dbItem.wid + ";");
        });

        var wduration = 0
        for(var j = 0; j < entries.length; j++){
            wduration += entries.item(j).duration
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
	width: listView.width
	menu: contextMenu

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
     Label {
         width: 400
	    text: model.wtitle
	    x: Theme.paddingLarge
	}
 Label {
     width: 50
	    text: model.wduration
	    x: Theme.paddingLarge
	}
 }
 
 

	onClicked: {
	    pageStack.push(Qt.resolvedUrl("WorkoutPerformancePage.qml"), {"currentWid": model.wid,
	    								    "currentWTitle": model.wtitle
	    								   })
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
    }

    PullDownMenu {
        MenuItem {
            text: qsTr("Clear local database")
            onClicked: {
                remorseClearDatabase.execute(qsTr("Database is going to be cleared"),
                function() {
                    Storage.clear();
                }
                )
            }
        }

        MenuItem {
            //% "Create workout"
            text: qsTrId("create-workout")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("WorkoutEditPage.qml"))
            }
        }


    }

    VerticalScrollDecorator {}
  }

}
