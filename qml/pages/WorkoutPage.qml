import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage
import "../js/env.js" as Env

Page {
  id: root
  
  property string table_prefix: "workout_"

  function createWorkoutList(){
    overviewModel.clear();

    var db = Storage.getDatabase();
    db.transaction(function(tx) {
        var rs = tx.executeSql("SELECT * FROM toc ORDER BY wtitle;");
        for(var i = 0; i < rs.rows.length; i++) {
            var dbItem = rs.rows.item(i);
            console.log("WName: " + dbItem.wtitle + " WID: " + dbItem.wid);
            overviewModel.append({"wid": dbItem.wid, "wtitle": dbItem.wtitle});
        }
    });
  }

  Component.onCompleted: {
    // Register components
    Env.components.setWorkoutEditPageComponent(workoutEditPageComponent)
    Env.components.setEditWorkoutSettingsComponent(editWorkoutSettingsComponent)
    Env.components.setEntryEditPageComponent(entryEditPageComponent)
    Env.components.setWorkoutPerformancePageComponent(workoutPerformancePageComponent)

    createWorkoutList();
  }
  
  ListModel {
    id: overviewModel
  }

  SilicaListView {
    id: listView
    anchors.fill: parent
    //spacing: 5

    model: overviewModel
    header: PageHeader { title: "Workouts" }
    delegate: ListItem {
	id: workoutDelegate
	width: listView.width
	menu: contextMenu

	function edit() {
	    pageStack.push(Env.components.workoutEditPageComponent, {"currentWid": wid})
	}

	function remove() {
	    remorseAction("Deleting", function() { 
			      Storage.deleteWorkout(wid);
			      listView.model.remove(index);
			  })
	}

	Label {
	    text: model.wtitle
	    x: Theme.paddingLarge
	}

	onClicked: {
	    console.log("START: " + model.wtitle)

	    pageStack.push(Env.components.workoutPerformancePageComponent, {"currentWid": model.wid,
	    								    "currentWTitle": model.wtitle
	    								   })
	}

	Component {
            id: contextMenu
            ContextMenu {
                MenuItem {
                    text: "Edit"
                    onClicked: edit()
                }
                MenuItem {
                    text: "Remove"
                    onClicked: remove()
                }
            }
        }
    }

    PullDownMenu {
	MenuItem {
	    text: "Add Workout"
	    onClicked: {
		console.log("ADD WORKOUT")
		pageStack.push(Env.components.editWorkoutSettingsComponent)
	    }
	}
    }

    VerticalScrollDecorator {}
  }

  Component {
      id: workoutEditPageComponent
      WorkoutEditPage { 
	  id: workoutEditPage
      }
  }

  Component {
      id: editWorkoutSettingsComponent
      EditWorkoutSettings { 
	  id: editWorkoutSettings
	  Component.onCompleted: workoutListChanged.connect(root.createWorkoutList)
      }
  }

  Component { 
      id: entryEditPageComponent
      EntryEditPage {
      }
  }

  Component { 
      id: workoutPerformancePageComponent
      WorkoutPerformancePage {
      }
  }

}
