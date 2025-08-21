cmake_minimum_required(VERSION 3.25.0)

project(TreelandProtocols VERSION 0.5.0)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)

include(GNUInstallDirs)

add_subdirectory(cmake)

set(XML
  xml/treeland-capture-unstable-v1.xml
  xml/treeland-output-manager-v1.xml
  xml/treeland-virtual-output-manager-v1.xml
  xml/treeland-dde-shell-v1.xml
  xml/treeland-personalization-manager-v1.xml
  xml/treeland-wallpaper-color-v1.xml
  xml/treeland-foreign-toplevel-manager-v1.xml
  xml/treeland-shortcut-manager-v1.xml
  xml/treeland-window-management-v1.xml
  xml/treeland-ddm-v1.xml
)

install(FILES ${XML} DESTINATION ${CMAKE_INSTALL_DATADIR}/treeland-protocols)
