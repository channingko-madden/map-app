/**
  * @file main.qml
  * @date 12/29/2022
  *
  * @brief MapApp main QML
  */

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Controls
import "./qml"

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("mapapp")

    // Primary layout of the app
    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            Layout.minimumWidth: 400
            Layout.leftMargin: 10
            Layout.rightMargin: 10


            // Grid that serves as the map
            GridSelectBox {
                id: mainMap
                Layout.alignment: Qt.AlignCenter
            }

            // Place buttons in a horizontal row
            RowLayout {
                Layout.alignment: Qt.AlignCenter

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

        Rectangle {
            border.color: "grey"
            border.width: 3
            color: "transparent"
            radius: 4
            Layout.fillWidth: true
            Layout.minimumWidth: label.implicitWidth + 20 // Padding
            Layout.preferredHeight: label.implicitHeight + 20 // Padding
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            Label {
                id: label
                text: "\nClick a tile to change the color:\n\n- Green: open path\n- Red: blocked path\n- Yellow: begin/end location\n"
                anchors.centerIn: parent
                font.pointSize: 12
            }
        }
    }
}
