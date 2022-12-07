/*!
  * @file GridSelectBox.qml
  * @date 12/7/2022
  *
  * @brief GridSelectBox Module
  * Displays a rectangular grid that represents a 2D occupancy grid map.
  *
  * The color of a rectangular grid represents information on the type of Vertex it is:
  *	  Yellow: Denotes the beginning/end of a path
  *   Red: Denotes the vertex contains an obstacle
  *   Green: Denotes the vertex does not contain an obstacle
  *   Orange: Denotes the vertex is part of the calculated path between beginning and end
  *
  * Grid functionality:
  * Clicking a grid space will change the color of the grid.
  * There can only be two yellow grid spaces (only one beginning and one end)
  *
  * There are methods that can be called for calculating the path, and clearing the
  * grid (restoring all grid spaces to Green).
  */

import QtQuick 2.15
import mapapp.gridmap

Grid {
    id: mapGrid
    columns: 5
    rows: 5
    spacing: 6
    property bool hasBegin: false // denote if a beginning vertex has been selected
    property bool hasEnd: false // denote if an end vertex has been selected

    // This enum represents the type of Vertex within the grid map
    enum Vertex {
        Begin,
        End,
        Obstacle,
        Open,
        Path
    }

    Repeater {
        id: rectRepeater
        model: 25
        Rectangle {
            id: mapRect
            property int vertexType: GridSelectBox.Vertex.Open
            color: "green"
            width: 20
            height: width

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (parent.vertexType === GridSelectBox.Vertex.Open) {
                        setVertexObstacle()
                    } else if (parent.vertexType === GridSelectBox.Vertex.Obstacle) {
                        if (!mapGrid.hasBegin) {
                            parent.vertexType = GridSelectBox.Vertex.Begin
                            parent.color = "yellow"
                            mapGrid.hasBegin= true
                        } else if (!mapGrid.hasEnd) {
                            parent.vertexType = GridSelectBox.Vertex.End
                            parent.color = "yellow"
                            mapGrid.hasEnd = true
                        } else {
                            setVertexOpen()
                        }
                    } else if (parent.vertexType === GridSelectBox.Vertex.Begin) {
                        setVertexOpen()
                        mapGrid.hasBegin = false
                    } else if (parent.vertexType === GridSelectBox.Vertex.End) {
                        setVertexOpen()
                        mapGrid.hasEnd = false
                    } else if (parent.vertexType === GridSelectBox.Vertex.Path) {
                        setVertexObstacle()
                    }
                }
            }

            function setVertexOpen() {
                this.vertexType = GridSelectBox.Vertex.Open
                this.color = "green"
            }

            function setVertexPath() {
                this.vertexType = GridSelectBox.Vertex.Path
                this.color = "orange"
            }

            function setVertexObstacle() {
                this.vertexType = GridSelectBox.Vertex.Obstacle
                this.color = "red"
            }
        }
    }

    // C++ object registered to QML for calculating the path
    GridMap {
        id: gridmap
    }

    // send the necessary data to the GridMap object
    function calculatePath()  {
        // connect to GridMap's signal to receive back the path data
        gridmap.pathData.connect(drawPath)
        const data = []
        let beginVertex = -1
        let endVertex = -1
        for (let i = 0; i < rectRepeater.count; ++i) {
            let vertex  = rectRepeater.itemAt(i)
            if (beginVertex === -1 && vertex.vertexType === GridSelectBox.Vertex.Begin) {
                beginVertex = i
            } else if (endVertex === -1 && vertex.vertexType === GridSelectBox.Vertex.End) {
                endVertex = i
            } else if (vertex.vertexType === GridSelectBox.Vertex.Path) {
                vertex.setVertexOpen()
            }

           data[i] = vertex.vertexType === GridSelectBox.Vertex.Obstacle
        }

        // check that there is indeed a begin and end position
        if (beginVertex >= 0 && endVertex >= 0) {
            gridmap.calculatePath(mapGrid.rows, mapGrid.columns, data, beginVertex, endVertex)
        } else {
            // ToDo: send error message to user!
        }
    }

    // clear the map by resetting every vertex to open, and noting that there is
    // no beginning or end vertex selected
    function clearMap() {
        for (let i = 0; i < rectRepeater.count; ++i) {
            rectRepeater.itemAt(i).setVertexOpen()
        }
        this.hasBegin = false
        this.hasEnd = false
    }


    // Slot that connects to GridMap.pathData signal
    // @param pathData A list of ints
    function drawPath(pathData) {
        for (let i = 0; i < pathData.length; ++i) {
            let vertex  = rectRepeater.itemAt(pathData[i])
            if (vertex.vertexType !== GridSelectBox.Vertex.Begin
                    && vertex.vertexType !== GridSelectBox.Vertex.End) {
                vertex.setVertexPath()
            }
        }
    }

}
