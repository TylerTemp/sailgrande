import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0

import "../components"
import "../Api.js" as API
import "../Helper.js" as Helper
import "../MediaStreamMode.js" as MediaStreamMode
import "../Storage.js" as Storage


Page {

    property var user
    property bool relationStatusLoaded : false
    property bool recentMediaLoaded: false;


    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + header.height + 10
        contentWidth: parent.width

        PageHeader {
            id: header
            title: "Welcome"
            description: user.username
        }

        Column {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            id: column

            Rectangle {
                height: 150
                width: parent.width
                color: "transparent"


                Rectangle {
                    anchors.fill: parent
                    color: Theme.highlightColor
                    opacity: mouseAreaMyProfile.pressed ? 0.3 : 0.1
                }

                UserDetailBlock {
                    id: userDetailBlock
                }

                MouseArea {
                    anchors.fill: parent
                    id: mouseAreaMyProfile
                    onClicked: pageStack.push(Qt.resolvedUrl("UserProfilPage.qml"),{user:user});
                }

            }

            StreamPreviewBlock {
                streamTitle: 'My Stream'
                mode : MediaStreamMode.MY_STREAM_MODE
            }

            StreamPreviewBlock {
                streamTitle: 'Popular'
                mode : MediaStreamMode.POPULAR_MODE
            }

            StreamPreviewBlock {
                property string favoriteTag : loadFavoriteTag()
                visible: favoriteTag!==""
                streamTitle: 'Tagged with ' + favoriteTag
                mode : MediaStreamMode.TAG_MODE
                tag: favoriteTag

                function loadFavoriteTag() {
                    return Storage.get("favtag","");

                }
            }
        }

        PullDownMenu {

            MenuItem {
                 text: qsTr("About")
                 onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))

             }


            MenuItem {
                 text: qsTr("Search")
                 onClicked: pageStack.push(Qt.resolvedUrl("TagSearchPage.qml"))

             }
        }



    }

    ListModel {
        id: recentMediaModel
    }


    Component.onCompleted: {
        reload();
    }

    function reload() {
        API.get_UserById('self',reloadFinished);
        //API.get_RecentMediaByUserId(user.id,recentMediaFinished)
    }

    function reloadFinished(data) {
        if(data.meta.code===200) {
            user = data.data;
        } else {
            privateProfile = true;
        }
    }

    function recentMediaFinished(data) {
        if(data === undefined || data.data === undefined) {
            recentMediaLoaded=true;
            return;
        }
        for(var i=0; i<data.data.length; i++) {
            recentMediaModel.append(data.data[i]);
        }
        recentMediaLoaded=true;

    }


}