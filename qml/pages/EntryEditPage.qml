import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Dialog {
  id: root
  property int currentWid: -1
  property int currentIid: -1
  property int currentIndex: -1
  property variant model: 0
  property string type: ""
  property bool edit: false
  
  // Data fields
  property alias duration: durationSlider.value
  property alias title: entryTitleTextField.text
  property alias description: entryDescriptionTextField.text

  Column {
      id: col
      width: parent.width
      spacing: Theme.paddingLarge

      DialogHeader {
        acceptText: {
	    if(type === "exercise"){
		edit ? "Set Exercise" : "Add Exercise"
	    }else{
		edit ? "Set Pause" : "Add Pause"
	    }
	} // acceptText
        title: {
	    if(type === "exercise"){
		edit ? "Set Exercise" : "Add Exercise"
	    }else{
		edit ? "Set Pause" : "Add Pause"	    
	    }
	} // title
      }

      TextField {
        id: entryTitleTextField
	visible: (type === "exercise")
        width: parent.width
        label: "Title"
        text: ""
        placeholderText: "Set Title (mandatory)"
      /* EnterKey.enabled: !errorHighlight */
      /* EnterKey.iconSource: "image://theme/icon-m-enter-next" */
      /* EnterKey.onClicked: entryUrlTextField.focus = true */
      /* onTextChanged: { */
      /*     editEntryDetailsDialog.titleChanged = */
      /*     (editEntryDetailsDialog.origTitle !== text ? true : false) */
      /*     editEntryDetailsDialog.updateCoverState() */
      /* } */
      /* focusOutBehavior: -1 // This doesn't let the eye button steal focus */
      }

      TextField {
        id: entryDescriptionTextField
	visible: (type === "exercise")
        width: parent.width
        label: "Description"
        text: ""
        placeholderText: "Set Description (optional)"
      }

      Slider {
	id: durationSlider
	width: parent.width
	label: "Exercise Duration"
    minimumValue: 0
	maximumValue: 300
	value: 20
    stepSize: 5
	valueText: value + "s"
      } 

  }// Column

  // user wants to save new entry data
  onAccepted: {
      if(type === "exercise"){
	  if(!edit){
	      console.log("SAVE EXERCISE to WID: " + root.currentWid);
	      var dbItem = Storage.addExerciseToWorkout(root.currentWid, root.title, root.duration, root.description);
	      root.model.append({"iid": dbItem["iid"], "title": dbItem["title"], "type": dbItem["type"], "duration": dbItem["duration"], "description": dbItem["description"]});
	  }else{
	      console.log("SET EXERCISE (WID: " + root.currentWid + ")");
	      var dbItem = Storage.setExerciseInWorkout(root.currentIid, root.currentWid, root.title, root.description, root.duration);
	      root.model.setProperty(root.currentIndex, "title", dbItem["title"]);
	      root.model.setProperty(root.currentIndex, "description", dbItem["description"]);
	      root.model.setProperty(root.currentIndex, "duration", dbItem["duration"]);
	  }
      }else{
	  if(!edit){
	      console.log("ADD PAUSE to WID: " + root.currentWid);
	      var dbItem = Storage.addPauseToWorkout(root.currentWid, durationSlider.value);
	      root.model.append({"iid": dbItem["iid"], "title": dbItem["title"], "type": dbItem["type"], "duration": dbItem["duration"], "description": dbItem["description"]});
	  }else{
	      console.log("SET PAUSE (WID: " + root.currentWid + ")");
	      var dbItem = Storage.setPauseInWorkout(root.currentWid, root.currentIid, durationSlider.value);
	      root.model.setProperty(root.currentIndex, "duration", dbItem["duration"]);
	  }
      }
  }

  // user has rejected editing entry data, check if there are unsaved details
  onRejected: {
      if(type === "exercise"){
	  console.log("CANCEL SET/ADD EXERCISE")
      }else{
	  console.log("CANCEL SET/ADD PAUSE")
      }
  }


}
