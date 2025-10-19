# map-app
An app with a map, created using Qt with a mix of QML and C++.

## Occupancy Map
This app presents the user a 2D occupancy map.

![Initial Screen](/docs/initial_screen.png)

The user can change the contents of the map, and calculate the
shortest path between a beginning and end point on the map.

![Showing Path](/docs/showing_path.png)

## Doxygen Documentation
HTML API documentation can be created using doxygen.  
The open source Doxygen filter [Doxyqml](https://invent.kde.org/sdk/doxyqml)
must be installed to create documentation for the QML files.
```bash
cd docs/
doxygen map_app.conf
```
The html documentation is created and placed in a directory named html,
located where the doxygen command was called.  
Documentation can then be viewed in a browser. To open from the terminal:
```bash
xdg-open docs/html/index.html
```

## Build

```bash
mkdir build
cd build
cmake .. -DQt6_DIR=<some_path>/Qt/6.X.X/<os>/lib/cmake/Qt6
cmake --build .
```
