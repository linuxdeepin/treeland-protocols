configure_file(TreelandProtocolsConfig.cmake.in TreelandProtocolsConfig.cmake @ONLY)
configure_file(TreelandProtocolsConfigVersion.cmake.in TreelandProtocolsConfigVersion.cmake @ONLY)
configure_file(treeland-protocols.pc.in treeland-protocols.pc @ONLY)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/TreelandProtocolsConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/TreelandProtocolsConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/TreelandProtocols)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/treeland-protocols.pc
    DESTINATION ${CMAKE_INSTALL_DATADIR}/pkgconfig)
