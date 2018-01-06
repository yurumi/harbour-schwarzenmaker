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

  Component.onDestruction: {
      // viewHelper.hideOverlay()
  }

  ListModel {
      id: overviewModel
  }

  Item {
      id: avatar
      width: parent.width
      height: avatarBody.height
      visible: false
      anchors{
          bottom: parent.bottom
      }

      Rectangle {
          anchors.fill: parent
          color: "red"
          opacity: 0.3
      }     

      Image {
          id: avatarBody
          fillMode: Image.PreserveAspectFit
          width: parent.width
          anchors.bottom: parent.bottom
          source: "qrc:/img/avatar_body.png"
      }

//      Image {
//          id: avatarHead
//          anchors {
//              horizontalCenter: parent.horizontalCenter
//              top: parent.top
//          }
//          source: "image://avatarimage/avatar_head"

//          MouseArea {
//              anchors.fill: parent
//              onClicked: {
//                  pageStack.push(Qt.resolvedUrl("DirectoryPage.qml"))
//              }
//          }
//      }
  }

  
  SilicaListView {
      id: listView
      anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          bottom: avatar.top
      }

      ViewPlaceholder {
          enabled: listView.count === 0
          text: qsTr("Pull down to create a workout.")
        }

      model: overviewModel
      header: PageHeader {
          title: qsTr("Workout Overview")
      }
      delegate: ListItem {
          id: workoutDelegate
          menu: contextMenu
          width: parent.width

          function edit() {
              pageStack.push(Qt.resolvedUrl("WorkoutEditPage.qml"), {"parentPage": root, "currentWid": wid, "currentWTitle": wtitle})
          }

          function duplicate() {
              var newWid = Storage.duplicateWorkout(wid)
              pageStack.push(Qt.resolvedUrl("WorkoutEditPage.qml"), {"parentPage": root, "currentWid": newWid, "currentWTitle": wtitle + " (dup)"})
              // createWorkoutList()
          }

          function remove() {
              remorseAction(qsTr("Deleting"), function() {
                  var _index = index
                  Storage.deleteWorkout(wid);
                  listView.model.remove(_index);
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
                  width: delegateRow.width - durationLBL.width
                  text: model.wtitle
              }
              
              Label {
                  id: durationLBL
                  width: 50 * Theme.pixelRatio
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
                      text: qsTr("Edit")
                      onClicked: edit()
                  }
                  MenuItem {
                      text: qsTr("Duplicate")
                      onClicked: duplicate()
                  }
                  MenuItem {
                      text: qsTr("Delete")
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
              text: qsTr("Create workout")
              onClicked: {
                  pageStack.push(Qt.resolvedUrl("WorkoutEditPage.qml"), {"parentPage": root})
              }
          }
      } // PullDownMenu

      VerticalScrollDecorator {}

  } // listview

}
