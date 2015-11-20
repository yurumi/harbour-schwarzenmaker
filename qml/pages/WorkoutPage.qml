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
      console.log("ON DESTRUCTION")
      // viewHelper.hideOverlay()
  }

  ListModel {
      id: overviewModel
  }

  Item {
      id: avatar
      width: parent.width
      height: avatarBody.height
      anchors{
          bottom: parent.bottom
          // horizontalCenter: parent.horizontalCenter
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

      Image {
          id: avatarHead
          anchors {
              horizontalCenter: parent.horizontalCenter
              top: parent.top
          }
          source: "image://avatarimage/avatar_head"

          MouseArea {
              anchors.fill: parent
              onClicked: {
                  pageStack.push(Qt.resolvedUrl("DirectoryPage.qml"))
              }
          }
      }
  }

  
  SilicaListView {
      id: listView
      anchors {
          left: parent.left
          right: parent.right
          top: parent.top
          bottom: avatar.top
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

          function remove() {
              remorseAction(qsTr("Deleting"), function() { 
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
                      text: qsTr("Edit workout")
                      onClicked: edit()
                  }
                  MenuItem {
                      text: qsTr("Remove workout")
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
