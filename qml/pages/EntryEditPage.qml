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
import "../js/storage.js" as Storage

Dialog {
  id: root

  readonly property string pageType: "EntryEdit"

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
                      edit ? qsTr("Save Exercise") : qsTr("Add Exercise")
                  }else{
                      edit ? qsTr("Save Pause") : qsTr("Add Pause")
                  }
              } // acceptText
          }

          TextField {
              id: entryTitleTextField
              visible: (type === "exercise")
              width: parent.width
              label: qsTr("Title")
              text: ""
              placeholderText: qsTr("Set Title")
          }

          TextField {
              id: entryDescriptionTextField
              visible: (type === "exercise")
              width: parent.width
              label: qsTr("Description")
              text: ""
              placeholderText: qsTr("Set Description (optional)")
          }

          Slider {
              id: durationSlider
              width: parent.width
              label: qsTr("Duration")
              minimumValue: 0
              maximumValue: 300
              value: 20
              stepSize: 5
              valueText: value + "s"
          } 

      }// Column
  }// Flickable
}
