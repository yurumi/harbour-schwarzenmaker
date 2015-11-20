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

  // user wants to save new entry data
  onAccepted: {
      if(type === "exercise"){
          if(!edit){
              var dbItem = Storage.addExerciseToWorkout(root.currentWid, root.title, root.duration, root.description);
              root.model.append({"iid": dbItem["iid"], "title": dbItem["title"], "type": dbItem["type"], "duration": dbItem["duration"], "description": dbItem["description"]});
          }else{
              var dbItem = Storage.setExerciseInWorkout(root.currentIid, root.currentWid, root.title, root.description, root.duration);
              root.model.setProperty(root.currentIndex, "title", dbItem["title"]);
              root.model.setProperty(root.currentIndex, "description", dbItem["description"]);
              root.model.setProperty(root.currentIndex, "duration", dbItem["duration"]);
          }
      }else{
          if(!edit){
              var dbItem = Storage.addPauseToWorkout(root.currentWid, durationSlider.value);
              root.model.append({"iid": dbItem["iid"], "title": dbItem["title"], "type": dbItem["type"], "duration": dbItem["duration"], "description": dbItem["description"]});
          }else{
              var dbItem = Storage.setPauseInWorkout(root.currentWid, root.currentIid, durationSlider.value);
              root.model.setProperty(root.currentIndex, "duration", dbItem["duration"]);
          }
      }
  }

  SilicaFlickable {
      anchors.fill: parent
      contentHeight: col.height
      Column {
          id: col
          width: parent.width
          spacing: Theme.paddingLarge

          DialogHeader {
              acceptText: {
                  if(type === "exercise"){
                      edit ? "Save Exercise" : "Add Exercise"
                  }else{
                      edit ? "Save Pause" : "Add Pause"
                  }
              } // acceptText
              // title: {
              //     if(type === "exercise"){
              //         edit ? "Save Exercise" : "Add Exercise"
              //     }else{
              //         edit ? "Save Pause" : "Add Pause"	    
              //     }
              // } // title
          }

          TextField {
              id: entryTitleTextField
              visible: (type === "exercise")
              width: parent.width
              label: "Title"
              text: ""
              placeholderText: "Set Title (mandatory)"
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
              label: "Duration"
              minimumValue: 0
              maximumValue: 300
              value: 20
              stepSize: 5
              valueText: value + "s"
          } 

      }// Column
  }// Flickable
}
