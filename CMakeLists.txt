# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

project (print)
cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.6)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)
#

# Base bits

#

enable_testing ()
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/print")
set (RELEASE_NAME "Print utility.")
set (VERSION "0.1")
set (CMAKE_C_FLAGS "-ggdb")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gtk+-3.0)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})
find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.14.0" MINIMUM)
include(ValaPrecompile)
vala_precompile(VALA_C
    src/pantheon-print.vala
PACKAGES
    gtk+-3.0
OPTIONS
    --vapidir=${CMAKE_CURRENT_SOURCE_DIR}/vapi/
)
add_executable (pantheon-print ${VALA_C})
install(TARGETS pantheon-print RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/print.contract DESTINATION share/contractor)
