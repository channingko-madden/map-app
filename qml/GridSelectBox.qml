/**
 * @file GridSelectBox.qml
 * @date 12/29/2022
 *
 * @brief GridSelectBox Module
 */

import QtQuick
import QtQuick.Dialogs
import mapapp.gridmap
import "./"
import "./gridselectbox"

/**
 * @brief A rectangular grid that represents a 2D occupancy grid map.
 *
 * This type has methods for calculating the path and clearing the grid
 *
 * Grid functionality:
 * - Clicking a grid space will change the state of that space.
 * - There can only be two grid spaces designated as the end points of the
 * path (aka. only one beginning and one end).
 *
 */
Grid {
    id: occupancyMap
    columns: 10
    rows: 10
    spacing: 6
    /** @brief type:bool Denote if a beginning vertex has been selected */
    property bool hasBegin: false
    /** @brief Denote if an end vertex has been selected */
    property bool hasEnd: false

    /**
     * @enum Vertex
     * @brief This enum represents the state of a Vertex within the grid map
     */
    enum Vertex {
        Begin,
        End,
        Obstacle,
        Open,
        Path
    }

    /** @brief C++ GridMap object registered to QML used for calculating the path */
    GridMap {
        id: gridmap
    }

    /**
     * @brief Error message for when the user tries to calculate a path,
     * but hasn't selected the beginning and end positions, which are required
     */
    MessageDialog {
        id: noBeginEndMsgDialog
        title: "Error"
        text: "An error occurred"
        informativeText: "To calculate a path, a beginning and ending position are required"
        buttons: MessageDialog.Ok
    }

    /** @brief Repeater that contains the vertexes within the grid */
    Repeater {
        id: rectRepeater
        model: occupancyMap.columns * occupancyMap.rows
        RectangleVertex {
        }

        // connect the slots to the signals of each vertex
        onItemAdded: function(index, item) {
            item.isEnding.connect(setEnding)
            item.isBeginning.connect(setBeginning)
        }
    }

    /**
     * @brief Set hasEnd flag
     *
     * A slot for a Vertex's isEnding signal
     * @param type:bool present True is user has set an end vertex, false otherwise
     */
    function setEnding(present) {
        hasEnd = present
    }

    /**
     * @brief Set hasBegin flag
     *
     * A slot for a Vertex's isBeginning signal
     * @param type:bool present True is user has set a begin vertex, false otherwise
     */
    function setBeginning(present) {
        hasBegin = present
    }

    /**
     * @brief Calculate the calculatePath
     *
     * Pass the grid data to the GridMap object for calculating the path
     * Open an error message dialog if any required data is missing, such as
     * the beginning and end positions of the path.
     */
    function calculatePath()  {
        // connect to GridMap's signal to receive back the path data
        gridmap.pathData.connect(drawPath)
        const data = []
        let beginVertex = -1
        let endVertex = -1
        for (let i = 0; i < rectRepeater.count; ++i) {
            let vertex  = rectRepeater.itemAt(i)
            if (beginVertex === -1 && vertex.state === GridSelectBox.Vertex.Begin) {
                beginVertex = i
            } else if (endVertex === -1 && vertex.state === GridSelectBox.Vertex.End) {
                endVertex = i
            } else if (vertex.state === GridSelectBox.Vertex.Path) {
                vertex.setVertexOpen()
            }

           data[i] = vertex.state === GridSelectBox.Vertex.Obstacle
        }

        // check that there is indeed a begin and end position
        if (beginVertex >= 0 && endVertex >= 0) {
            gridmap.calculatePath(occupancyMap.rows, occupancyMap.columns, data, beginVertex, endVertex)
        } else {
            noBeginEndMsgDialog.open() // send error message to user!
        }
    }

    /**
     * @brief Clear the map

     * Reset every vertex to open, and set that there is
     * no beginning or end vertex selected
     */
    function clearMap() {
        for (let i = 0; i < rectRepeater.count; ++i) {
            rectRepeater.itemAt(i).setVertexOpen()
        }
        hasBegin = false
        hasEnd = false
    }

    /**
     * @brief Draw the path on the map
     *
     * Slot that connects to the GridMap.pathData signal
     * @param type:QList<int> pathData A list of ints containing the indexes of the
     * vertices that form the path
     */
    function drawPath(pathData) {
        for (let i = 0; i < pathData.length; ++i) {
            let vertex  = rectRepeater.itemAt(pathData[i])
            if (vertex.state !== GridSelectBox.Vertex.Begin
                    && vertex.state !== GridSelectBox.Vertex.End) {
                vertex.setVertexPath()
            }
        }
    }
}
