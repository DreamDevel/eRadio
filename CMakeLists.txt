
project (eradio)
cmake_minimum_required (VERSION 2.6)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set(GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
add_definitions("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
add_definitions("-w")

set (HOMEDIR $ENV{HOME})
set (HOME_DATADIR ${HOMEDIR}/.local/share/eradio)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/eradio")

set (EXEC_NAME "eradio")
set (RELEASE_NAME "eRadio")
set (VERSION "1.0")
set (VERSION_INFO "First Release")

set (CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala)
set (CONFIG_FILE_REL src/config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala.cmake ${CONFIG_FILE})

include (GSettings)
add_schema ("schemas/org.dreamdev.eradio.gschema.xml")

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
    src/settings.vala
PACKAGES
    ${PROJECT_DEPS}
)

add_subdirectory (po)

add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/eradio.desktop DESTINATION ${DATADIR}/applications/)

set(SYSTEM_DEFAULT_THEME ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/16x16/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/16x16/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/24x24/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/24x24/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/32x32/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/32x32/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/48x48/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/48x48/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/64x64/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/64x64/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/96x96/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/96x96/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/128x128/apps/eradio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/128x128/apps)