configure_file(TreelandProtocolsConfig.cmake.in TreelandProtocolsConfig.cmake)
configure_file(treeland-protocols.pc.in treeland-protocols.pc)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/TreelandProtocolsConfig.cmake
    DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/TreelandProtocols/)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/treeland-protocols.pc
    DESTINATION ${CMAKE_INSTALL_DATADIR}/pkgconfig)
