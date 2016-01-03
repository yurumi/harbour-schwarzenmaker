/*
  Based on:
  gPodder QML UI Reference Implementation
  Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
  --> Thanks!

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


IconButton {
    property alias text: lbl.text

    Label {
        id: lbl
        opacity: parent.down
        Behavior on opacity {
            FadeAnimation {}
        }

        anchors {
            verticalCenter: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
    }
}
