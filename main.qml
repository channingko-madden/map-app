import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "./qml"

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("map-app")

    // Primary layout of the app
    ColumnLayout {
        anchors.centerIn: parent

        // Grid that serves as the map
        GridSelectBox {
            id: mainMap
            Layout.alignment: Qt.AlignCenter
        }


       RowLayout {

           // calculate button
           Button {
               id: calculateButton
               Layout.alignment: Qt.AlignCenter
               text: "Calculate Path"

               /* send a signal that the button has been pressed,
                  and within the signal pass the map data
               */
               onClicked: {
                   mainMap.sendMapData()
               }
           }

           Button {
               id: clearButton
               Layout.alignment: Qt.AlignCenter
               text: "Clear Map"

               onClicked: {
                   mainMap.clearMap()
               }
           }
       }
    }
}
