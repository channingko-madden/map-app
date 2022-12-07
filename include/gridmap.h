/**
 * @file gridmap.h
 * @date 12/7/2022
 *
 * @brief GridMap class
 *
 * This class should be registered in QML with the uri of mapapp.gridmap
 */

#ifndef GRIDMAP_H
#define GRIDMAP_H

#include <QObject>
#include <QList>
#include <vector>

/**
 * @class GridMap gridmap.h "gridmap.h"
 * @brief The GridMap class
 *
 * This class treats a rectangular grid as an occupancy grid map.
 * A grid space can be marked as containing a obstacle (true) or not (false).
 * Each grid space is labeled according to its position within the grid, starting with
 * grid space 0 located in the upper left corner, and travesering row by row. For example,
 * a 3x3 grid has spaces labeled:
 * 	0 1 2
 * 	3 4 5
 *  6 7 8
 *
 * The occupancy grid is used to calculate the shortest path from a start and
 * end location.
 */
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
     * @param mapData Occupancy grid data. First data point is the upper-left corner of the grid,
     * and subsequent data points are ordered left to right, (row), then top to bottom. True
     * means the grid point contains an obstacle, false means it does not.
     * @param beginIndex The index within mapData indicating the beginning of the path
     * @param endIndex The index within mapData indicating the end of the path
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
     * Send data containing the optimal path, if one is possible
     * @param pathData Contains values representing the index within the grid map of the
     * points that form the path. An empty list means there is no possible path.
     */
    void pathData(QList<int> pathData);

private:

    /**
     * @brief createAdjacencyMatrix
     * Create the adjacency matrix for the 2D occupancy grid map, assuming each point on the
     * grid is a vertex within a graph.
     * @param rows Number of rows the 2D grid has (aka column length)
     * @param cols Number of columns the 2D grid has (aka row length)
     * @param mapData Occupancy grid data.
     * @return A symmetric adjacency matrix
     */
    std::vector<std::vector<bool>> createAdjacencyMatrix(
            const int rows,
            const int cols,
            const QList<bool>& mapData) const;

    /**
     * @brief minVertexDistance
     * "minimal currDist(v)" portion of Dijkstra algorithm.
     * Finds a new vertex with the minimal distance and returns the index to it
     * @param distances Vector that contains the distance from the beginning vertex
     *  to a given vertex
     * @param sptSet Sortest Path Tree Set - contains the indexes for vertices that
     * are already within the shortest path.
     * @return Index of vertex with the minimal distance
     */
    int minVertexDistance(
            const std::vector<int>& distances,
            const std::vector<bool>& sptSet) const;

    /**
     * @brief dijkstra
     * Dijkstra algorithm for finding the shortest path between a start and end position
     * @param adjacencyMatrix The adjacency matrix
     * @param startIndex Index of where the path begins
     * @param endIndex Index of where the path ends
     * @return List of indexes for each vertex within the path.
     * If there is no possible path, then the returned list will be empty
     */
    QList<int> dijkstra(
            const std::vector<std::vector<bool>>& adjacencyMatrix,
            const int beginIndex,
            const int endIndex) const;

};

#endif // GRIDMAP_H
