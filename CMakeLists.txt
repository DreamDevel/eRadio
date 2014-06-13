
project (eradio)
cmake_minimum_required (VERSION 2.6)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (HOMEDIR $ENV{HOME})
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/eradio")

set (EXEC_NAME "eradio")
set (RELEASE_NAME "eRadio")
set (VERSION "1.0 Beta")
set (VERSION_INFO "First Release")

set (CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala)
set (CONFIG_FILE_REL src/config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala.cmake ${CONFIG_FILE})

find_package(PkgConfig)

set (PROJECT_DEPS
    gstreamer-0.10
    gtk+-3.0
    granite
    sqlite3
    gee-1.0
)

pkg_check_modules(DEPS REQUIRED ${PROJECT_DEPS})

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
	${CONFIG_FILE_REL}
    src/main.vala
    src/radio.vala
    src/main_window.vala
    src/stream_player.vala
    src/station_list.vala
    src/stations.vala
    src/station.vala
    src/error.vala
    src/station_dialog.vala
PACKAGES
    ${PROJECT_DEPS}
)

add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icon.png DESTINATION ${PKGDATADIR})
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/eradio.desktop DESTINATION ${DATADIR}/applications/)