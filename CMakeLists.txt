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
        DESCRIPTION "A CMake module to share several functionalities used across C / C++ projects."
        HOMEPAGE_URL "https://github.com/TBlauwe/tcm"
        VERSION 1.0.0
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
    add_subdirectory(tests/arguments)
    add_subdirectory(tests/benchmark)
    add_subdirectory(tests/simple)
    add_subdirectory(tests/shared_static)
    add_test(NAME Logging COMMAND ${CMAKE_COMMAND} -B ${CMAKE_CURRENT_BINARY_DIR}/tests/logging -S ${CMAKE_CURRENT_SOURCE_DIR}/tests/logging)
    add_subdirectory(tests/utility)
    add_subdirectory(tests/test)
    add_subdirectory(tests/examples)
    add_subdirectory(tests/ispc)
else()
    add_subdirectory(tests/emscripten)
endif ()

tcm_setup_docs(
        FILES docs/pages
        ASSETS assets
)
