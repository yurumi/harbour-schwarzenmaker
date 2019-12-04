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

Page {
    id: aboutPage
    /* onStatusChanged: pgst.handlePageStatusChange(status) */

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        VerticalScrollDecorator { flickable: flickable }

        contentWidth: aboutColumn.width
        contentHeight: aboutColumn.height + aboutColumn.spacing

        Column {
            id: aboutColumn

            width: aboutPage.width
            spacing: Theme.paddingMedium


            PageHeader {
                title: "About Schwarzenmaker"
            }

            Column {
                spacing: Theme.paddingLarge

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Image {
                    width: parent.width / 4
                    height: width
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("qrc:/harbour-schwarzenmaker.png")
                    smooth: false
                }

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    text: "© 2015-2019 Thomas Eigel\nLicense: GPLv3 or later"
                }

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    text: "\nIf you use Schwarzenmaker regularly, please consider contributing."
                }

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        text: "<b>Issues/Ideas/PRs:<\b>"
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        text: "https://github.com/yurumi/harbour-schwarzenmaker"
                    }
                }

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        text: "<b>Heads up:<\b>"
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        text: "comments @ jolla store"
                    }
                }

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                   
                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        text: "<b>Beer/Coffee:<\b>"
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        text: "yurumi@gmx.de (PayPal)"
                    }
                }

            }
        }
    }
}
