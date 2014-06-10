
project (radio)

cmake_minimum_required (VERSION 2.6)

# Define where cmake modules are
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/radio")
set (EXEC_NAME "radio")
set (RELEASE_NAME "Radio")
set (VERSION "0.1")
set (VERSION_INFO "First Release")

set (CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/src/config.vala.cmake ${CONFIG_FILE})
set (CONFIG_FILE_REL src/config.vala)

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

set (program_DEPS
    gtk+-3.0
    granite
)


# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED ${program_DEPS}) # Modules Required
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)

# make sure we use vala
include(ValaVersion)

# make sure it's the desired version of vala
ensure_vala_version("0.16" MINIMUM)

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
	${CONFIG_FILE_REL}
    src/main.vala
    src/radio.vala
    src/main_window.vala
# tell what libraries to use when compiling
PACKAGES
    ${program_DEPS}
)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install our .desktop file so the Applications menu will see it
# install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/hello.desktop DESTINATION ${DATADIR}/applications/)