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

  readonly property string pageType: "EditWorkoutSettings"

  property string origTitle: ""

  signal workoutListChanged

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
