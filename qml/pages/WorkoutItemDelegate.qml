import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

ListItem {
  id: workoutItemDelegate
  width: parent.width
  menu: contextMenu
  /* height: if(type === "pause"){40}else{80} */

  property int titleRowHeight: 40
  property int descriptionRowHeight: 40
  property variant model: 0
  property int wid: -1

  function edit() {
  /* pageStack.push(editWorkoutExercisePage) */
  }
  
  function remove() {
      remorseAction("Deleting", function() {
  		      Storage.deleteItemFromWorkout(workoutItemDelegate.wid, workoutItemDelegate.iid);
  		      workoutItemDelegate.model.remove(index);
		      Storage.printWorkout(workoutItemDelegate.wid)
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

  
  /* Component.onCompleted: { */
  /*   if(type === "pause"){ */
  /*     descriptionRowHeight = 0 */
  /*     descriptionRect.visible = false */
  /*   } */
  /* } */

  /* Label { */
  /*     text: if(type === "pause"){"Pause"}else{title} */
  /*     x: Theme.paddingLarge */
  /* } */

  /* Column{ */
    Row {
	Label {
	    width: workoutItemDelegate.width / 3 * 2
	    text: if(type === "pause"){"Pause"}else{title}
	}
	Label {
            width: workoutItemDelegate.width / 3
	    text: if(type === "pause"){duration}else{""}
	}

  /*     Rectangle { */
  /*       id: titleRect */
  /*       width: workoutItemDelegate.width / 3 * 2 */
  /*       height: titleRowHeight */
  /*       color: if(type === "pause"){"cyan"}else{"blue"} */
  /*       Text { */
  /*         anchors.fill: parent */
  /*         text: if(type === "pause"){"Pause"}else{title} */
  /*       } */
  /*     } */
  /*     Rectangle { */
  /*       width: workoutItemDelegate.width - titleRect.width */
  /*       height: titleRowHeight */
  /*       color: "yellow" */
  /*       Text { */
  /*         anchors.centerIn: parent */
  /*         text: duration */
  /*       } */
  /*     } */
  /*   }// Row */
  /*   Rectangle { */
  /*     id: descriptionRect */
  /*     width: workoutItemDelegate.width */
  /*     height: descriptionRowHeight */
  /*     color: "red" */
  /*     Text { */
  /*       anchors.fill: parent */
  /*       text: description */
  /*     } */
    }
  /* }// Column */
}
