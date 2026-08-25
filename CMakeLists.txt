cmake_minimum_required(VERSION 3.25.0)

project(TreelandProtocols VERSION 0.5.10 LANGUAGES NONE)

# https://gitlab.kitware.com/cmake/cmake/-/work_items/23461
# Suppress GNUInstallDirs warning for LANGUAGES NONE projects
if(NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR "lib")
endif()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Public protocol XML files (for general application developers)
set(TREELAND_PROTOCOL_XML_FILES
  public/treeland-capture-unstable-v1.xml
  public/treeland-dde-shell-v1.xml
)

# DDE component protocol XML files
set(TREELAND_PROTOCOL_DDE_XML_FILES
  dde/treeland-foreign-toplevel-manager-v1.xml
  dde/treeland-input-manager-unstable-v1.xml
  dde/treeland-keyboard-state-notify-unstable-v1.xml
  dde/treeland-output-manager-v1.xml
  dde/treeland-personalization-manager-v1.xml
  dde/treeland-shortcut-manager-v2.xml
  dde/treeland-virtual-output-manager-v1.xml
  dde/treeland-wallpaper-manager-unstable-v1.xml
  dde/treeland-window-management-v1.xml
)

# Internal protocol XML files (Treeland-specific, not for general app developers)
set(TREELAND_PROTOCOL_INTERNAL_XML_FILES
  internal/treeland-app-id-resolver-v1.xml
  internal/treeland-ddm-v1.xml
  internal/treeland-prelaunch-splash-v2.xml
  internal/treeland-screensaver-v1.xml
  internal/treeland-wallpaper-shell-unstable-v1.xml
)

# Wine-specific protocol XML files
set(TREELAND_PROTOCOL_WINE_XML_FILES
  wine/treeland-remote-subsurface-unstable-v1.xml
  wine/treeland-wine-window-management-unstable-v1.xml
  wine/treeland-wine-window-state-unstable-v1.xml
)

# Deprecated protocol XML files (replaced by newer versions)
set(TREELAND_PROTOCOL_DEPRECATED_XML_FILES
  deprecated/treeland-prelaunch-splash-v1.xml
  deprecated/treeland-shortcut-manager-v1.xml
  deprecated/treeland-wallpaper-color-v1.xml
)

option(TREELAND_PROTOCOLS_INSTALL_DEPRECATED "Install deprecated protocol files" ON)

# Install protocol XML files
install(FILES ${TREELAND_PROTOCOL_XML_FILES} ${TREELAND_PROTOCOL_DDE_XML_FILES} ${TREELAND_PROTOCOL_INTERNAL_XML_FILES} ${TREELAND_PROTOCOL_WINE_XML_FILES}
  DESTINATION ${CMAKE_INSTALL_DATADIR}/treeland-protocols
)

if(TREELAND_PROTOCOLS_INSTALL_DEPRECATED)
  install(FILES ${TREELAND_PROTOCOL_DEPRECATED_XML_FILES}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/treeland-protocols
  )
endif()

# Generate and install CMake package config files
configure_package_config_file(
  cmake/TreelandProtocolsConfig.cmake.in TreelandProtocolsConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/TreelandProtocols
)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/TreelandProtocolsConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
  ARCH_INDEPENDENT
)
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/TreelandProtocolsConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/TreelandProtocolsConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/TreelandProtocols
)

# Generate and install pkg-config file
configure_file(cmake/treeland-protocols.pc.in treeland-protocols.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/treeland-protocols.pc"
  DESTINATION ${CMAKE_INSTALL_DATADIR}/pkgconfig
)
