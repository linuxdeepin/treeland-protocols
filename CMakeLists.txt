cmake_minimum_required(VERSION 3.25.0)

project(TreelandProtocols VERSION 0.9.0 LANGUAGES NONE)

# https://gitlab.kitware.com/cmake/cmake/-/work_items/23461
# Suppress GNUInstallDirs warning for LANGUAGES NONE projects
if(NOT CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR "lib")
endif()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Public protocol XML files (for general application developers)
set(TREELAND_PROTOCOL_XML_FILES
  public/treeland-snap-target-unstable-v1.xml
  public/treeland-window-transition-unstable-v1.xml
  public/treeland-appearance-unstable-v1.xml
  public/treeland-decoration-unstable-v1.xml
  public/treeland-output-uuid-unstable-v1.xml
  public/treeland-output-uuid-head-unstable-v1.xml
)

# DDE component protocol XML files
set(TREELAND_PROTOCOL_DDE_XML_FILES
  dde/treeland-dde-shell-unstable-v2.xml
  dde/treeland-foreign-toplevel-manager-unstable-v3.xml
  dde/treeland-input-manager-unstable-v1.xml
  dde/treeland-keyboard-state-notify-unstable-v1.xml
  dde/treeland-output-manager-unstable-v2.xml
  dde/treeland-shortcut-manager-unstable-v3.xml
  dde/treeland-compositor-action-unstable-v1.xml
  dde/treeland-appearance-manager-unstable-v1.xml
  dde/treeland-output-group-manager-unstable-v1.xml
  dde/treeland-wallpaper-manager-unstable-v1.xml
  dde/treeland-layer-shell-extension-unstable-v1.xml
  dde/treeland-xwindow-control-unstable-v1.xml
  dde/treeland-active-notify-unstable-v1.xml
  dde/treeland-region-watch-unstable-v1.xml
  dde/treeland-activation-token-unstable-v1.xml
)

# Internal protocol XML files (Treeland-specific, not for general app developers)
set(TREELAND_PROTOCOL_INTERNAL_XML_FILES
  internal/treeland-app-id-resolver-unstable-v2.xml
  internal/treeland-prelaunch-splash-unstable-v2.xml
  internal/treeland-screensaver-unstable-v2.xml
  internal/treeland-wallpaper-shell-unstable-v1.xml
)

# Wine-specific protocol XML files
set(TREELAND_PROTOCOL_WINE_XML_FILES
  wine/treeland-remote-subsurface-unstable-v1.xml
  wine/treeland-wine-window-management-unstable-v1.xml
  wine/treeland-wine-window-state-unstable-v1.xml
)

# Deprecated protocol XML files (replaced by newer versions), limited to the
# ones still needed by consumers of the installed package. Files whose
# implementation was removed and that no consumer scans any more are kept in
# deprecated/ for reference but not installed.
set(TREELAND_PROTOCOL_DEPRECATED_XML_FILES
  deprecated/treeland-capture-unstable-v1.xml
  deprecated/treeland-ddm-v1.xml
  deprecated/treeland-personalization-manager-v1.xml
  deprecated/treeland-dde-shell-v1.xml
  deprecated/treeland-wallpaper-color-v1.xml
  # No longer implemented by Treeland, but dde-shell still generates client code
  # from it (shell/CMakeLists.txt, panels/notification/osd/brightness/CMakeLists.txt).
  # Drop once dde-shell has migrated to treeland-output-manager-unstable-v2.
  deprecated/treeland-output-manager-v1.xml
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
