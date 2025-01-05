# ------------------------------------------------------------------------------
#           File : CMakeLists.txt
#         Author : TBlauwe
#    Description : Root CMakeLists.txt.
#
#   /!\ Project should not be consumed /!\
#   It won't do / break anything, but there is no reason to.
#   It's role is to generate `tcm.cmake` and test it.
#   Just include `cmake/tcm.cmake`.
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.26)

project(TCM
        DESCRIPTION "A CMake module to reduce boilerplate"
        HOMEPAGE_URL "https://github.com/TBlauwe/tcm"
        VERSION 1.1.0
)

# Guard against consumption.
if(NOT PROJECT_IS_TOP_LEVEL)
    return()
endif()

# Generate script
add_subdirectory(src)


# ------------------------------------------------------------------------------
# --- TESTS
# ------------------------------------------------------------------------------
include(cmake/tcm.cmake)

enable_testing()
if(NOT EMSCRIPTEN)
    # Create a dummy library for testing
    add_library(my_lib SHARED tests/my_lib/my_lib.c)
    target_include_directories(my_lib PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/tests/my_lib/include>)
    tcm_target_export_header(my_lib)

    add_library(my_lib_static STATIC tests/my_lib/my_lib.c)
    target_include_directories(my_lib_static PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/tests/my_lib/include>)
    tcm_target_export_header(my_lib_static BASE_NAME my_lib) # We must set BASE_NAME to the one used by source files.

    add_subdirectory(tests/arguments)
    add_subdirectory(tests/benchmark)
    add_subdirectory(tests/examples)
    add_subdirectory(tests/ispc)
    add_test(NAME Logging COMMAND ${CMAKE_COMMAND} -B ${CMAKE_CURRENT_BINARY_DIR}/tests/logging -S ${CMAKE_CURRENT_SOURCE_DIR}/tests/logging)
    add_subdirectory(tests/shared_static)
    add_subdirectory(tests/simple)
    add_subdirectory(tests/test)
    add_subdirectory(tests/utility)
else()
    add_subdirectory(tests/emscripten)
endif ()

set(DOXYGEN_PROJECT_LOGO ${PROJECT_SOURCE_DIR}/assets/logo_small_dark.png)
tcm_documentation(
        FILES docs/pages tests/my_lib
        ASSETS assets
)
