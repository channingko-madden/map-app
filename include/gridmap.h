#ifndef GRIDMAP_H
#define GRIDMAP_H

#include <QObject>
#include <QList>
#include <vector>

class GridMap : public QObject
{
    Q_OBJECT
public:
    explicit GridMap(QObject *parent = nullptr);

    /**
     * @brief calculatePath
     * Calculate the shortest path from beginning to end, given map data identifying obstacles
     * within the map.
     * @param row The number of rows of the grid that represents the map
     * @param column The number of columns of the grid that represents the map
     * @param mapData The grid data. First data point is the upper-left corner of the grid,
     * and subsequent data points are ordered left to right, (row), then top to bottom
     * @param beginIndex The index within mapData indicating the beginning vertice
     * @param endIndex The index within mapData indicating the end vertice
     */
    Q_INVOKABLE void calculatePath(
            int row,
            int column,
            QList<bool> mapData,
            int beginIndex,
            int endIndex);

signals:
    /**
     * @brief pathData
     * Send data containing the optimal path
     * @param pathData Contains values representing the index within the grid map of the
     * points that form the path
     */
    void pathData(QList<int> pathData);

private:

    /**
     * @brief createAdjacencyMatrix
     * Create the adjacency matrix for the 2D grid map, assuming each point on the grid is a
     * node within a graph.
     * @param rows Number of rows the 2D grid has (aka column length)
     * @param cols Number of columns the 2D grid has (aka row length)
     * @param mapData The grid data. First data point is the upper-left corner of the grid,
     * and subsequent data points are ordered left to right, (row), then top to bottom
     * (column)
     * @return An adjacency matrix (rows and columns stand for graph vertices).
     */
    std::vector<std::vector<bool>> createAdjacencyMatrix(
            const int rows,
            const int cols,
            QList<bool> mapData) const;

    /**
     * @brief setAjacencyValues
     * Set the correct values within the adjacency matrix
     * @param matrix
     * @param vertex
     * @param rows
     * @param cols
     */
    void setAdjacencyValues(
            const bool isBlocked,
            std::vector<std::vector<bool>>& matrix,
            const size_t vertex,
            const int rows,
            const int cols) const;

    /**
     * @brief minVertexDistance
     * "minimal currDist(v)" portion of Dijkstra algorithm.
     * Finds a new vertex with the minimal distance and returns the index to it
     * @param distances Distance from
     * @param sptSet Sortest Path Tree Set - contains the indexes for vertices that
     * are already within the shortest path.
     * @return Index of vertex with the minimal distance
     */
    int minVertexDistance(std::vector<int>& distances, std::vector<bool> sptSet) const;

    /**
     * @brief dijkstra
     * Dijkstra algorithm for finding the shortest path between a start and end position
     * @param adjacencyMatrix The adjacency matrix
     * @param startIndex Index of where the path begins
     * @param endIndex Index of where the path ends
     * @return List of indexes for each vertex within the path. An empty list signifies
     * there is no possible path from beginning to end.
     */
    QList<int> dijkstra(
            std::vector<std::vector<bool>>& adjacencyMatrix,
            int beginIndex,
            int endIndex) const;


};

#endif // GRIDMAP_H
