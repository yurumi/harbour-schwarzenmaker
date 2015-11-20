import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.schwarzenmaker.FileModel 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    property string dir: "/home/nemo"
    property bool initial: false // this is set to true if the page is initial page

    FileModel {
        id: fileModel
        dir: page.dir
        // page.status does not exactly work - root folder seems to be active always??
        active: page.status === PageStatus.Active
    }

    SilicaListView {
        id: fileList
        anchors.fill: parent
        clip: true

        model: fileModel

        VerticalScrollDecorator { flickable: fileList }

        header: PageHeader {
            title: qsTr("Choose Image File")
            // title: Functions.formatPathForTitle(page.dir) + " " +
            //        Functions.unicodeBlackDownPointingTriangle()
            // MouseArea {
            //     anchors.fill: parent
            //     onClicked: dirPopup.show();
            // }
        }

        delegate: ListItem {
            id: fileItem
            // menu: contextMenu
            width: ListView.view.width
            contentHeight: listLabel.height+listLabel.height + 13

            // background shown when item is selected
            // Rectangle {
            //     visible: isSelected
            //     anchors.fill: parent
            //     color: fileItem.highlightedColor
            // }

            // Image {
            //     id: listIcon
            //     anchors.left: parent.left
            //     anchors.leftMargin: Theme.paddingLarge
            //     anchors.top: parent.top
            //     anchors.topMargin: 11
            //     source: "../images/small-"+fileIcon+".png"
            // }
            // circle shown when item is selected
            // Label {
            //     visible: isSelected
            //     anchors.left: parent.left
            //     anchors.leftMargin: Theme.paddingLarge-4
            //     anchors.top: parent.top
            //     anchors.topMargin: 3
            //     text: "\u25cb"
            //     color: Theme.highlightColor
            //     font.pixelSize: Theme.fontSizeLarge
            // }
            Label {
                id: listLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.top: parent.top
                anchors.topMargin: 5
                text: filename
                elide: Text.ElideRight
                color: Theme.primaryColor
            }
            // Label {
            //     id: listSize
            //     anchors.left: listIcon.right
            //     anchors.leftMargin: 10
            //     anchors.top: listLabel.bottom
            //     text: !(isLink && isDir) ? size : Functions.unicodeArrow()+" "+symLinkTarget
            //     color: fileItem.highlighted || isSelected ? Theme.secondaryHighlightColor : Theme.secondaryColor
            //     font.pixelSize: Theme.fontSizeExtraSmall
            // }
            // Label {
            //     visible: !(isLink && isDir)
            //     anchors.top: listLabel.bottom
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     text: filekind+permissions
            //     color: fileItem.highlighted || isSelected ? Theme.secondaryHighlightColor : Theme.secondaryColor
            //     font.pixelSize: Theme.fontSizeExtraSmall
            // }
            // Label {
            //     visible: !(isLink && isDir)
            //     anchors.top: listLabel.bottom
            //     anchors.right: listLabel.right
            //     text: modified
            //     color: fileItem.highlighted || isSelected ? Theme.secondaryHighlightColor : Theme.secondaryColor
            //     font.pixelSize: Theme.fontSizeExtraSmall
            // }

            onClicked: {
                if(model.isDir){
                    pageStack.push(Qt.resolvedUrl("DirectoryPage.qml"), { dir: fileModel.appendPath(listLabel.text) });
                }else{
                    console.log("File selected: ", fileModel.appendPath(listLabel.text))
                    avatarImageProvider.loadImageFile(listLabel.text);
                    pageStack.pop();
                }
            }

            // // context menu is activated with long press
            // Component {
            //      id: contextMenu
            //      ContextMenu {
            //          // cancel delete if context menu is opened
            //          onActiveChanged: { remorsePopup.cancel(); clearSelectedFiles(); }
            //          MenuItem {
            //              text: qsTr("Cut")
            //              onClicked: engine.cutFiles([ fileModel.fileNameAt(index) ]);
            //          }
            //          MenuItem {
            //              text: qsTr("Copy")
            //              onClicked: engine.copyFiles([ fileModel.fileNameAt(index) ]);
            //          }
            //          MenuItem {
            //              text: qsTr("Delete")
            //              onClicked:  {
            //                  deleteFile(fileModel.fileNameAt(index));
            //              }
            //          }
            //          MenuItem {
            //              visible: model.isDir
            //              text: qsTr("Properties")
            //              onClicked:  {
            //                  pageStack.push(Qt.resolvedUrl("FilePage.qml"),
            //                                 { file: fileModel.fileNameAt(index) });
            //              }
            //          }
            //      }
            //  }
        } // delegate

        // text if no files or error message
        Text {
            width: parent.width
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            horizontalAlignment: Qt.AlignHCenter
            y: -fileList.contentY + 100
            visible: fileModel.fileCount === 0 || fileModel.errorMessage !== ""
            text: fileModel.errorMessage !== "" ? fileModel.errorMessage : qsTr("No files")
            color: Theme.highlightColor
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            // update cover
            //     coverPlaceholder.text = Functions.lastPartOfPath(page.dir)+"/";

            // go to Home on startup
            if (page.initial) {
                page.initial = false;
                Functions.goToHome();
            }
        }
    }

    // DirPopup {
    //     id: dirPopup
    //     anchors.fill: parent
    //     menuTop: 100
    // }

    // connect signals from engine to panels
    // Connections {
    //     target: engine
    //     onProgressChanged: progressPanel.text = engine.progressFilename
    //     onWorkerDone: progressPanel.hide()
    //     onWorkerErrorOccurred: {
    //         // the error signal goes to all pages in pagestack, show it only in the active one
    //         if (progressPanel.open) {
    //             progressPanel.hide();
    //             if (message === "Unknown error")
    //                 filename = qsTr("Trying to move between phone and SD Card? It doesn't work, try copying.");
    //             else if (message === "Failure to write block")
    //                 filename = qsTr("Perhaps the storage is full?");

    //             notificationPanel.showText(message, filename);
    //         }
    //     }
    // }

    // NotificationPanel {
    //     id: notificationPanel
    //     page: page
    // }

    // ProgressPanel {
    //     id: progressPanel
    //     page: page
    //     onCancelled: engine.cancel()
    // }

}


