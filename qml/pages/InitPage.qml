import QtQuick 2.0
/* import QtMultimedia 5.0 */
import Sailfish.Silica 1.0

Page {
  id: root
  
  BusyIndicator {
      anchors.centerIn: parent
      running: true
      size: BusyIndicatorSize.Large
  } 

  /* SoundEffect { */
  /*   id: playSound */
  /*   source: "soundeffect.wav" */
  /* } */
  
  Component.onCompleted: {
      console.log("INIT PAGE FINISHED")
      /* playSound.play() */
  }
}
