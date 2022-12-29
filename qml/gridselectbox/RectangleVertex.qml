/*!
  * @file RectangleVertex.qml
  * @date 12/29/2022
  *
  * @brief RectangleVertex Module
  *
  */

import QtQuick 2.15

import "../"

/**
 * @brief A rectangular shaped vertex of an occupancy grid
 *
 * Assumptions: This type is meant to be used within a GridSelectBox with an id of
 * "occupancyMap" and that has hasBegin and hasEnd bool properties.
 *
 * The color of a rectangular grid represents information on the type of Vertex it is:
 * - Yellow: Denotes the beginning/end of a path
 * - Red: Denotes the vertex contains an obstacle
 * - Green: Denotes the vertex does not contain an obstacle
 * - Orange: Denotes the vertex is part of the calculated path between beginning and end
 */
Rectangle {
    id: mapRect
    /** @brief type:int The state of this Vertex */
    property int state: GridSelectBox.Vertex.Open
    color: "green"
    width: 20
    height: width

    /**
     * @brief Signal this Vertex has been set or unset as the End
     * @param present True if Vertex represents the End, false if it no longer does
     */
    signal isEnding(bool present)
    /**
     * @brief Signal this Vertex has been set or unset as the Beginning
     * @param present True if Vertex represents the Beginning, false if it no longer does
     */
    signal isBeginning(bool present)

    // capture clicks and change the state accordingly
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (parent.state === GridSelectBox.Vertex.Open) {
                setVertexObstacle()
            } else if (parent.state === GridSelectBox.Vertex.Obstacle) {
                if (!occupancyMap.hasBegin) {
                    parent.state = GridSelectBox.Vertex.Begin
                    parent.color = "yellow"
                    mapRect.isBeginning(true)
                } else if (!occupancyMap.hasEnd) {
                    parent.state = GridSelectBox.Vertex.End
                    parent.color = "yellow"
                    mapRect.isEnding(true)
                } else {
                    setVertexOpen()
                }
            } else if (parent.state === GridSelectBox.Vertex.Begin) {
                setVertexOpen()
                mapRect.isBeginning(false)
            } else if (parent.state === GridSelectBox.Vertex.End) {
                setVertexOpen()
                mapRect.isEnding(false)
            } else if (parent.state === GridSelectBox.Vertex.Path) {
                setVertexObstacle()
            }
        }
    }


    /**
     * @brief Set the state of this vertex to Open
     *
     * Change color of vertex to green
     */
    function setVertexOpen() {
        this.state = GridSelectBox.Vertex.Open
        this.color = "green"
    }

    /**
     * @brief Set the state of this vertex to Path
     *
     * Change color of vertex to orange
     */
    function setVertexPath() {
        this.state = GridSelectBox.Vertex.Path
        this.color = "orange"
    }

    /**
     * @brief Set the state of this vertex to Obstacle
     *
     * Change color of vertex to red
     */
    function setVertexObstacle() {
        this.state = GridSelectBox.Vertex.Obstacle
        this.color = "red"
    }
}
