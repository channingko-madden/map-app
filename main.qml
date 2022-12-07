/**
  * @file main.qml
  * @date 12/7/2022
  *
  * @brief MapApp main QML
  */

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

        // Place buttons in a horizontal row
        RowLayout {

            // button to trigger path calculation
            Button {
                id: calculateButton
                Layout.alignment: Qt.AlignCenter
                text: "Calculate Path"

                onClicked: {
                    mainMap.calculatePath()
                }
           }

            // button to clear the map
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
