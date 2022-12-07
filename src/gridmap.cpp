/**
 * @file gridmap.cpp
 * @date 12/7/2022
 *
 * @brief Definition of GridMap class
 *
 */

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
    const auto matrix = createAdjacencyMatrix(row, column, mapData);

    // calculate shortest path using the adjacency matrix and send it to UI!
    emit pathData(dijkstra(matrix, beginIndex, endIndex));
}

std::vector<std::vector<bool>> GridMap::createAdjacencyMatrix(
        const int rows,
        const int cols,
        const QList<bool>& mapData) const {

    std::vector<std::vector<bool>> matrix(rows * cols, std::vector(rows * cols, false));

    // here the index (vertex) corresponds to the vertex label
    for (auto vertex = 0; vertex < mapData.size(); ++vertex) {
        /*
         * For any given vertex label = N, it could be the adjacent vertex N-1 to the left,
         * vertex N+1 to the right, vertex N - cols above, and vertex N + cols below
         */
       auto row = vertex / cols; // row that the vertex is within
       auto col = vertex - (row * cols); // col that the vertex is within
       if (col != 0) { // there can be a vertex to the left
           matrix[vertex][vertex - 1] = !(mapData[vertex] || mapData[vertex - 1]);
           matrix[vertex - 1][vertex] = !(mapData[vertex] || mapData[vertex - 1]);//symmetric
       }
       if (col < cols - 1) { // there can be a vertex to the right
           matrix[vertex][vertex + 1] = !(mapData[vertex] || mapData[vertex + 1]);
           matrix[vertex + 1][vertex] = !(mapData[vertex] || mapData[vertex + 1]);
       }
       if (row != 0) { // there can be a vertex above
          matrix[vertex][vertex - cols] = !(mapData[vertex] || mapData[vertex - cols]);
          matrix[vertex - cols][vertex] = !(mapData[vertex] || mapData[vertex - cols]);
       }
       if (row < rows - 1) { // there can be a vertex below
          matrix[vertex][vertex + cols] = !(mapData[vertex] | mapData[vertex + cols]);
          matrix[vertex + cols][vertex] = !(mapData[vertex] | mapData[vertex + cols]);
       }
    }

    return matrix;
}

int GridMap::minVertexDistance(
        const std::vector<int>& distances,
        const std::vector<bool>& sptSet) const {

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
        const std::vector<std::vector<bool>>& adjacencyMatrix,
        const int beginIndex,
        const int endIndex) const {

    std::vector<bool> spt(adjacencyMatrix.size(), false); // shortest path tree

    // initialize the distances vector
    std::vector<int> distances(adjacencyMatrix.size(), std::numeric_limits<int>::max());
    distances[beginIndex] = 0; // initialize distance from start to start as 0

    /* This is the "previous" vector
     * Each index corresponds to a grid space, and the value at the index is the
     * previous grid space from the path which led to this one
    */
    std::vector<int> prevs(adjacencyMatrix.size(), -1);

    auto minIndex = minVertexDistance(distances, spt);
    while (minIndex >= 0) {

        spt[minIndex] = true;

        /* Update the distance from the current vertex to all vertex it is adjacent to,
         * ignoring the vertices already within the path.
         * For weighted graph, also need to check:
         *  distances[minIndex] + adjacencyMatrix[minIndex][v] < distances[v]
         */
        for (auto v = 0; v < adjacencyMatrix.size(); ++v) {
           if ( !spt[v]
                && adjacencyMatrix[minIndex][v] // there is an edge between spaces
                && distances[minIndex] != std::numeric_limits<int>::max()) {
               distances[v] = distances[minIndex] + 1; // change to weight of edge in future!
               prevs[v] = minIndex;
           }
        }

        // Don't need to proceed with the algorithm any further if the end is found
        if (spt[endIndex]) {
            qDebug() << "dijkstra finished";
            break;
        }

        minIndex = minVertexDistance(distances, spt);
    }

    // determine the path by moving backwards for the endIndex using the prevs array
    QList<int> shortestPath;

    if (prevs[endIndex] < 0) { // there is no path
        return shortestPath;
    }

    shortestPath.push_back(endIndex);
    auto index = endIndex;
    while (prevs[index] >= 0) { // start index has a previous of -1
        index = prevs[index];
        shortestPath.push_back(index);
    }

    {
        auto debugOut = qDebug();
        for (const auto& point : shortestPath) {
            debugOut << point;
        }
    }

    return shortestPath;
}
