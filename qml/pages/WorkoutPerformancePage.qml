import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage
import "../js/env.js" as Env

Page {
  id: root
  property int currentWid: -1
  property string currentWTitle: ""
  property int activeEntry: -1
  property int entryDurationMs: 0
  property int entryElapsedTimeMs: 0

  function buildEntriesModel(workout_name){
    entriesModel.clear();

    var db = Storage.getDatabase();
    db.transaction(function(tx) {
		     var rs = tx.executeSql("SELECT * FROM " + workout_name + ";");
		     for(var i = 0; i < rs.rows.length; i++) {
		       var dbItem = rs.rows.item(i);
		       entriesModel.append({"iid": dbItem.iid, "title": dbItem.title, "type": dbItem.type, "duration": dbItem.duration * 1000, "description": dbItem.description});
		     }
		   });
  }

  function proceed(){
      activeEntry += 1;

      console.log("PROCEED: ", activeEntry, " (", entriesModel.count, ")")
      
      if(activeEntry < entriesModel.count){
          var entry = entriesModel.get(root.activeEntry);
          entryDurationMs = entry.duration
          entryElapsedTimeMs = 0;
          if(entry.type === "pause"){
              entryTitle.text = "Pause";
          }else{
              entryTitle.text = entry.title;
          }
          entryTimer.start();
      }else{
          console.log("RETURN TRANSITION")
          pageStack.pop()
      }
  }

  Component.onCompleted: {
    buildEntriesModel("workout_" + root.currentWid);
    proceed();
  }

  SoundEffect {
    id: playSound
    source: "qrc:/sounds/blip.wav"
  }

  ListModel {
    id: entriesModel
  }

  /* SilicaListView { */
  /*   id: listView */
  /*   anchors.fill: parent */
  /*   header: PageHeader { title: root.currentWRTitle + " Excercises" } */
  /*   highlightFollowsCurrentItem: true */
  /*   model: entriesModel */

  /*   delegate: ListItem { */
  /*     id: workoutItemDelegate */
  /*     width: parent.width */
  /*     height: root.height */

  /*     Column { */
  /* 	Row { */
  /* 	  Label { */
  /* 	    width: workoutItemDelegate.width / 3 * 2 */
  /* 	    text: if(type === "pause"){"Pause"}else{title} */
  /* 	    color: if(type === "pause"){Theme.secondaryColor}else{Theme.primaryColor} */
  /* 	  } */
  /* 	  Label { */
  /* 	    id: remainingTimeLabel */
  /* 	    width: workoutItemDelegate.width / 3 */
  /* 	    text: duration */
  /* 	    color: if(type === "pause"){Theme.secondaryColor}else{Theme.primaryColor} */
  /* 	  } */
  /* 	} // Row */

  /* 	Label { */
  /* 	  id: descriptionLabel */
  /* 	  width: workoutItemDelegate.width / 3 * 2 */
  /* 	  text: if(type === "pause"){"PPPP"}else{description} */
  /* 	  font.pixelSize: Theme.fontSizeTiny */
  /* 	  visible: (type === "exercise") ? true : false */
  /* 	} */
  /*     } // Column */
  /*   } // delegate */
  /* } */
	
  Timer {
      id: entryTimer
      interval: 1000
      repeat: true
      triggeredOnStart: true
      onTriggered: {
          console.log("blank")
          appLibrary.setBlankingMode(true)

          var remainingTimeMs = root.entryDurationMs - root.entryElapsedTimeMs;

          // switch to next exercise or pause
          if(remainingTimeMs < 0){
              console.log("NEXT ENTRY");
              root.proceed();
              entryDuration.text = root.entryDurationMs / 1000;
          }else{
              entryDuration.text = remainingTimeMs / 1000;

              // play sound for the last few seconds
              if(remainingTimeMs <= 2000){
                  console.log("SOUND")
                  playSound.play();
              }
          }

          entryElapsedTimeMs += entryTimer.interval;
      }  
  }

  Text {
    id: entryTitle
    anchors.centerIn: parent
    height: 100
    width: 100
    color: Theme.highlightColor
  }

  Text {
    id: entryDuration
    anchors.left: entryTitle.left
    anchors.right: entryTitle.right
    anchors.top: entryTitle.bottom
    color: Theme.highlightColor
    height: 50
  }
 
}
