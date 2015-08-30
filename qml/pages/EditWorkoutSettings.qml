import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Dialog {
  id: root
  
  property string origTitle: ""

  signal workoutListChanged

  /* function setTextFields(title, url, username, password, comment) { */
  /*     entryTitleTextField.text = origTitle = title */
  /*     entryUrlTextField.text = origUrl = url */
  /*     entryUsernameTextField.text = origUsername = username */
  /*     entryPasswordTextField.text = entryVerifyPasswordTextField.text = origPassword = password */
  /*     entryCommentTextField.text = origComment = comment */
  /* } */

    /* // This function should be called when any text is changed to check if the */
    /* // cover page state needs to be updated */
    /* function updateCoverState() { */
    /*     if (titleChanged || urlChanged || usernameChanged || passwordChanged || commentChanged) { */
    /*         applicationWindow.cover.state = "UNSAVED_CHANGES" */
    /*     } else { */
    /*         applicationWindow.cover.state = "ENTRY_VIEW" */
    /*     } */
    /* } */

  Column {
      id: col
      width: parent.width
      spacing: Theme.paddingLarge

      DialogHeader {
          acceptText: "Save"
          title: "Save"
      }

      TextField {
          id: entryTitleTextField
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

  }// Column

  // user wants to save new entry data
  onAccepted: {
      console.log("SAVE WORKOUT")
      Storage.createWorkout(entryTitleTextField.text)
      root.workoutListChanged()
  }

  // user has rejected editing entry data, check if there are unsaved details
  onRejected: {
      console.log("CANCEL WORKOUT")
  }


}
