# file: CMakeLists.txt
# date: 12/7/2022

cmake_minimum_required(VERSION 3.16)

project(map-app VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(MAP_APP_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(MAP_APP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)


find_package(Qt6 6.2 COMPONENTS Quick REQUIRED)
find_package(Qt6 COMPONENTS Core REQUIRED)

qt_add_executable(appmap-app
    main.cpp
    ${MAP_APP_SOURCE_DIR}/gridmap.cpp
    ${MAP_APP_INCLUDE_DIR}/gridmap.h
)

qt_add_qml_module(appmap-app
    URI map-app
    VERSION 1.0
    QML_FILES main.qml
    qml/GridSelectBox.qml
    qml/gridselectbox/RectangleVertex.qml
)

set_target_properties(appmap-app PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(appmap-app PUBLIC
    ${MAP_APP_INCLUDE_DIR}
)

target_link_libraries(appmap-app
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Core)

install(TARGETS appmap-app
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
