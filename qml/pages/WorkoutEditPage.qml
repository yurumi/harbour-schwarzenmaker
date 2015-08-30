import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage
import "../js/env.js" as Env

Page {
    id: root
    property int currentWid: -1
    property string currentWTitle: ""

    function showWorkout(workout_name){
	workoutModel.clear();

	var db = Storage.getDatabase();
	db.transaction(function(tx) {
			   var rs = tx.executeSql("SELECT * FROM " + workout_name + ";");
			   for(var i = 0; i < rs.rows.length; i++) {
			       var dbItem = rs.rows.item(i);
			       workoutModel.append({"iid": dbItem.iid, "title": dbItem.title, "type": dbItem.type, "duration": dbItem.duration, "description": dbItem.description});
			   }
		       });
    }

    Component.onCompleted: {
	showWorkout("workout_" + root.currentWid);
    }

    ListModel {
	id: workoutModel
    }
  
    SilicaListView {
	anchors.fill: parent
	header: PageHeader { title: root.currentWTitle + " Excercises" }
	model: workoutModel

	/* delegate: WorkoutItemDelegate {model: workoutModel; wid: root.currentWid} */
	delegate: ListItem {
	  id: workoutItemDelegate
	  width: parent.width
	  menu: contextMenu

	  /* property int titleRowHeight: 40 */
	  /* property int descriptionRowHeight: (type === "pause") ? 0 : 40 */
	  /* height: (type === "pause") ? 40 : (40 + descriptionLabel.height) */
	  property variant model: root.workoutModel
	  property int wid: root.currentWid

	  function edit() {
	    console.log("EDIT ENTRY for WID: " + root.currentWid + " IID: " + iid + " duration: " + duration)
	    pageStack.push(Env.components.entryEditPageComponent, {"currentWid": root.currentWid,
	    							   "currentIid": iid,
	    							   "currentIndex": index,
	    							   "model": workoutModel,
	    							   "type": type,
	    							   "edit": true,
	    							   "title": title,
	    							   "description": description,
	    							   "duration": duration})
	  }
  
	  function remove() {
	    remorseAction("Deleting", function() {
  			    Storage.deleteItemFromWorkout(workoutItemDelegate.wid, iid);
  			    workoutModel.remove(index);
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

	  Column {
	    Row {
	      Label {
		width: workoutItemDelegate.width / 3 * 2
		text: if(type === "pause"){"Pause"}else{title}
		color: if(type === "pause"){Theme.secondaryColor}else{Theme.primaryColor}
	      }
	      Label {
		width: workoutItemDelegate.width / 3
		text: duration
		color: if(type === "pause"){Theme.secondaryColor}else{Theme.primaryColor}
	      }
	    } // Row

	    Label {
	      id: descriptionLabel
	      width: workoutItemDelegate.width / 3 * 2
	      text: if(type === "pause"){"PPPP"}else{description}
	      font.pixelSize: Theme.fontSizeTiny
	      visible: (type === "exercise") ? true : false
	    }
	  } // Column
	} // delegate

	PullDownMenu {
	    MenuItem {
		text: "Workout Settings"
		onClicked: {
		    console.log("WORKOUT SETTINGS")
		    pageStack.push(Env.components.EditWorkoutSettingsComponent)
		}
	    }
	}


	PushUpMenu {
	    MenuItem {
		text: "Add Exercise"
		onClicked: {
		    console.log("ADD EXERCISE")
		    pageStack.push(Env.components.entryEditPageComponent, {"currentWid": root.currentWid, 
								       "model": workoutModel,
								       "type": "exercise",
								       "edit": false})
		}
	    }
	    MenuItem {
		text: "Add Pause"
		onClicked: {
		    console.log("ADD PAUSE for WID: " + root.currentWid)
		    pageStack.push(Env.components.entryEditPageComponent, {"currentWid": root.currentWid, 
								       "model": workoutModel,
								       "type": "pause",
								       "edit": false})
		}
	    }
	}

	VerticalScrollDecorator {}

    }
}
