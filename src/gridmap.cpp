#include "gridmap.h"
#include <QDebug>
#include <limits>

GridMap::GridMap(QObject *parent)
    : QObject{parent} {

}

void GridMap::calculatePath(
        int row,
        int column,
        QList<bool> mapData,
        int beginIndex,
        int endIndex) {
    qDebug() << "calculatePath called rows: " << row << " cols: " << column;
    auto matrix = createAdjacencyMatrix(row, column, mapData);

    /*
    for (const auto& row : matrix) {
        auto dOut = qDebug(); // create QDebug object, it prints on destruction
        for (const auto& col : row) {
            dOut << col; // build string
        }
    }
    */

    // calculate shortest path using the adjacency matrix and send it to UI!
    emit pathData(dijkstra(matrix, beginIndex, endIndex));
}

std::vector<std::vector<bool>> GridMap::createAdjacencyMatrix(
        const int rows,
        const int cols,
        QList<bool> mapData) const {
    std::vector<std::vector<bool>> matrix(rows * cols, std::vector(rows * cols, false));

    /* Lets label the nodes according to their index within mapData.
     * For example, the first node 0 could possibly be adjacent to node 1 or node 0 + row
     * For any given node label = N, it could be the adjacent node N-1 to the left, node N+1
     * to the right, node N - cols above, and node N + cols below
     */

    // here i corresponds to the node label
    for (auto vertex = 0; vertex < mapData.size(); ++vertex) {
        //setAdjacencyValues(mapData[i], matrix, i, rows, cols);
       auto row = vertex / cols;
       auto col = vertex - (row * cols);
       //qDebug() << "row: " << row << " col: " << col;
       if (col != 0) { // there can be a node to the left
           matrix[vertex][vertex - 1] = !(mapData[vertex] || mapData[vertex - 1]);
           matrix[vertex - 1][vertex] = !(mapData[vertex] || mapData[vertex - 1]);//symmetric
       }
       if (col < cols - 1) {// there can be a node to the right
           matrix[vertex][vertex + 1] = !(mapData[vertex] || mapData[vertex + 1]);
           matrix[vertex + 1][vertex] = !(mapData[vertex] || mapData[vertex + 1]);
       }
       if (row != 0) { // there can be a node above
          matrix[vertex][vertex - cols] = !(mapData[vertex] || mapData[vertex - cols]);
          matrix[vertex - cols][vertex] = !(mapData[vertex] || mapData[vertex - cols]);
       }
       if (row < rows - 1) { // there can be a node below
          matrix[vertex][vertex + cols] = !(mapData[vertex] | mapData[vertex + cols]);
          matrix[vertex + cols][vertex] = !(mapData[vertex] | mapData[vertex + cols]);
       }
    }

    return matrix;
}

void GridMap::setAdjacencyValues(
        const bool isBlocked,
        std::vector<std::vector<bool>>& matrix,
        const size_t vertex,
        const int rows,
        const int cols) const {

       auto row = vertex / cols;
       auto col = vertex - (row * cols);
       //qDebug() << "row: " << row << " col: " << col;
       if (col != 0) { // there can be a node to the left
           matrix[vertex][vertex-1] = !isBlocked;
           matrix[vertex-1][vertex] = !isBlocked; // symmetric!
       }
       if (col < cols - 1) {// there can be a node to the right
           matrix[vertex][vertex+1] = !isBlocked;
           matrix[vertex+1][vertex] = !isBlocked;
       }
       if (row != 0) { // there can be a node above
          matrix[vertex][vertex-cols] = !isBlocked;
          matrix[vertex-cols][vertex] = !isBlocked;
       }
       if (row < rows - 1) { // there can be a node below
          matrix[vertex][vertex+cols] = !isBlocked;
          matrix[vertex+cols][vertex] = !isBlocked;
       }
}

int GridMap::minVertexDistance(std::vector<int>& distances, std::vector<bool> sptSet) const {
   auto min = std::numeric_limits<int>::max();  // initialize the minimum distance
   auto min_index = -1;
   for (auto i = 0; i < distances.size(); ++i) {
       if (!sptSet[i] && distances[i] <= min) {
           min = distances[i];
           min_index = i;
       }
   }
   return min_index;
}

QList<int> GridMap::dijkstra(
        std::vector<std::vector<bool>>& adjacencyMatrix,
        int beginIndex,
        int endIndex) const {


    std::vector<bool> spt(adjacencyMatrix.size(), false); // shortest path tree


    // initialize the calculate distances matrix
    std::vector<int> distances(adjacencyMatrix.size(), std::numeric_limits<int>::max());
    // beginning index will always have -1 as the prev!
    std::vector<int> prevs(adjacencyMatrix.size(), -1);
    distances[beginIndex] = 0; // initialize distance from start to start as 0

    // update this to only run until the destination is found! Don't need to
    // proceed with the algorithm any further
    for (auto i = 0; i < adjacencyMatrix.size() - 1; ++i) {
        auto minIndex = minVertexDistance(distances, spt);

        spt[minIndex] = true;

        // update the distance from the current node to all nodes it is adjacent to,
        // ignoring the nodes already within the path
        // for weighted graph, also check distances[minIndex + adjacencyMatrix[minIndex][v] < distances[v]
        for (auto v = 0; v < adjacencyMatrix.size(); ++v) {
           if ( !spt[v]
                && adjacencyMatrix[minIndex][v] // there is an edge
                && distances[minIndex] != std::numeric_limits<int>::max()) {
               distances[v] = distances[minIndex] + 1; // change to weight of edge in future!
               prevs[v] = minIndex;
           }
        }

        if (minIndex == endIndex) {
            break;
        }
    }

    // determine the path by moving backwards for the endIndex using the prevs array
    QList<int> shortestPath;

    auto index = endIndex;
    shortestPath.push_back(endIndex);
    while(prevs[index] > 0) { // start index is at -1
        index = prevs[index];
        shortestPath.push_back(index);
    }
    shortestPath.push_back(beginIndex);

    // If there is no possible path, then shortestPath will only contain the start and
    // end index

    {
        auto debugOut = qDebug();
        for (const auto& point : shortestPath) {
            debugOut << point;
        }
    }

    return shortestPath;
}
