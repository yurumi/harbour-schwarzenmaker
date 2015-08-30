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

  SoundEffect {
    id: playSound
    /* source: "/home/nemo/test.wav" */
    source: "test.wav"
  }


  /* property variant soundEffect: audioengine.sounds["explosion"].newInstance(); */

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
    playSound.play();
  }

  function startNextEntry(){
    root.activeEntry += 1;
    var entry = entriesModel.get(root.activeEntry);
    root.entryDurationMs = entry.duration
    root.entryElapsedTimeMs = 0;
    if(entry.type === "pause"){
      entryTitle.text = "Pause";
    }else{
      entryTitle.text = entry.title;
    }
    entryTimer.start();
  }

  Component.onCompleted: {
    buildEntriesModel("workout_" + root.currentWid);
    startNextEntry();
  }

  /* AudioEngine { */
  /*   id:audioengine */

  /*   AudioSample { */
  /*     name:"explosion01" */
  /*     source: "/usr/share/skype/sounds/CallBusy.wav" */
  /*   } */

  /*   Sound { */
  /*     name:"explosion" */
  /*     PlayVariation { */
  /*       sample:"explosion01" */
  /*     } */
  /*   } */
  /* } */
  
  ListModel {
    id: entriesModel
  }

  /* SilicaListView { */
  /*   id: listView */
  /*   anchors.fill: parent */
  /*   header: PageHeader { title: root.currentWTitle + " Excercises" } */
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
      /* playMusic.play(); */
      playSound.play();
      /* root.soundEffect.play(); */  

      var remainingTimeMs = root.entryDurationMs - root.entryElapsedTimeMs;

      if(remainingTimeMs < 0){
	console.log("NEXT ENTRY");
	root.startNextEntry();
	entryDuration.text = root.entryDurationMs / 1000;
      }else{
	entryDuration.text = remainingTimeMs / 1000;
      }

      entryElapsedTimeMs += entryTimer.interval;

    }  

    /* Audio { */
    /*   id: playMusic */
    /*   source: "/usr/share/skype/sounds/CallBusy.wav" // Point this to a suitable sound file */
    /* } */

    /* SoundEffect { */
    /*   id: playSound */
    /*   source: "/usr/share/skype/sounds/CallBusy.wav" */
    /* } */
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
