
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
set (PKG_DATADIR ${PKGDATADIR})

set (EXEC_NAME "eradio")
set (RELEASE_NAME "eRadio")
set (VERSION "1.2")

set (CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala)
set (CONFIG_FILE_REL src/config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala.cmake ${CONFIG_FILE})

include (GSettings)
add_schema ("schemas/org.dreamdev.eradio.gschema.xml")

find_package(PkgConfig)

set (PROJECT_DEPS
    gstreamer-1.0
    gtk+-3.0
    granite
    sqlite3
    gee-0.8
    libnotify
    json-glib-1.0
    libsoup-2.4
    libxml-2.0
    sqlheavy-0.1
)

pkg_check_modules(DEPS REQUIRED ${PROJECT_DEPS})

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.24" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
    ${CONFIG_FILE_REL}
    src/main.vala
    src/radio.vala
    src/error.vala
    src/package_manager.vala

    src/Enums/PlayerStatus.vala
    src/Enums/ListStoreFilterType.vala

    src/Models/Genre.vala
    src/Models/Station.vala

    src/Core/Database.vala
    src/Core/Player.vala
    src/Core/PlayerHelper.vala
    src/Core/MPRIS.vala
    src/Core/MediaKeyListener.vala
    src/Core/Notifier.vala
    src/Core/Settings.vala
    src/Core/DatabaseModels/GenreModel.vala
    src/Core/DatabaseModels/StationModel.vala
    src/Core/DatabaseModels/StationsGenresModel.vala
    src/Core/PlayerDecoders/M3UDecoder.vala
    src/Core/PlayerDecoders/PLSDecoder.vala
    src/Core/PlayerDecoders/ASXDecoder.vala

    src/UserInterface/Menus/ApplicationMenu.vala
    src/UserInterface/Menus/StationsTreeViewContextMenu.vala

    src/UserInterface/Views/WelcomeView.vala
    src/UserInterface/Views/StationsListView.vala

    src/UserInterface/Widgets/HeaderBar.vala
    src/UserInterface/Widgets/SideBar.vala
    src/UserInterface/Widgets/ViewStack.vala
    src/UserInterface/Widgets/StationsListStore.vala
    src/UserInterface/Widgets/GenresListStore.vala
    src/UserInterface/Widgets/StationsTreeView.vala
    src/UserInterface/Widgets/StationsTreeViewScrollable.vala
    src/UserInterface/Widgets/GenresTreeView.vala
    src/UserInterface/Widgets/GenresTreeViewScrollable.vala
    src/UserInterface/Widgets/GenresTreeViewToolbar.vala
    src/UserInterface/Widgets/SideBarExpandableItem.vala

    src/UserInterface/Dialogs/StationDialog.vala
    src/UserInterface/Dialogs/AddStationDialog.vala
    src/UserInterface/Dialogs/EditStationDialog.vala
    src/UserInterface/Dialogs/ErrorDialog.vala
    src/UserInterface/Dialogs/ProgressDialog.vala
    src/UserInterface/Dialogs/ImportProgressDialog.vala

    src/UserInterface/Others/FileChooserCreator.vala

    src/UserInterface/Windows/MainWindow.vala
PACKAGES
    ${PROJECT_DEPS}
OPTIONS
--enable-experimental
)

add_subdirectory (po)

add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/eradio.desktop DESTINATION ${DATADIR}/applications/)

set(SYSTEM_DEFAULT_THEME ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/notify.png DESTINATION ${PKGDATADIR})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/16x16/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/16x16/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/24x24/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/24x24/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/32x32/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/32x32/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/48x48/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/48x48/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/128x128/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/64x64/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/256x256/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/96x96/apps)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/images/icons/512x512/apps/eRadio.png DESTINATION ${SYSTEM_DEFAULT_THEME}/128x128/apps)
