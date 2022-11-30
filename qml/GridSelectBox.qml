import QtQuick 2.15
import appmap.gridmap

Grid {
    id: mapGrid
    columns: 5
    rows: 5
    spacing: 6
    property bool hasBegin: false
    property bool hasEnd: false

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

    GridMap {
        id: gridmap
    }


    // send int - row
    // send int - column
    // send a QList<int> denoting blocked or not blocked
    function sendMapData()  {
        gridmap.pathData.connect(drawPath) // connect signal to receive the path data
        const data = []
        let startVertex = -1
        let endVertex = -1
        for (let i = 0; i < rectRepeater.count; ++i) {
            let vertex  = rectRepeater.itemAt(i)
            if (startVertex === -1 && vertex.vertexType === GridSelectBox.Vertex.Begin) {
                startVertex = i
            } else if (endVertex === -1 && vertex.vertexType === GridSelectBox.Vertex.End) {
                endVertex = i
            } else if (vertex.vertexType === GridSelectBox.Vertex.Path) {
                vertex.setVertexOpen()
            }


           data[i] = vertex.vertexType === GridSelectBox.Vertex.Obstacle
        }

        // check that there is indeed a start and end position
        if (startVertex >= 0 && endVertex >= 0) {
            gridmap.calculatePath(mapGrid.rows, mapGrid.columns, data, startVertex, endVertex)
        } else {
            // ToDo: send error message to user!
        }
    }

    // clear the map by resetting color to green and isBlocked to false
    function clearMap() {
        for (let i = 0; i < rectRepeater.count; ++i) {
            rectRepeater.itemAt(i).setVertexOpen()
        }
        this.hasBegin = false
        this.hasEnd = false
    }


    // pathData is a list of ints
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
