# ------------------------------------------------------------------------------
#           File : CMakeLists.txt
#         Author : TBlauwe
#    Description : Root CMakeLists.txt. Useful only for dev mode (to test tcm.cmake)
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.21)

project(TCM
        DESCRIPTION "A CMake Script to provide several functionalities shared across C / C++ projects."
        HOMEPAGE_URL "https://github.com/TBlauwe/tcm"
)

if(NOT PROJECT_IS_TOP_LEVEL)
    return() # If consumed, we should do nothing as this file is only for testing purposes
endif()

add_subdirectory(src) # Generate tcm.cmake

# ------------------------------------------------------------------------------
# --- TESTS
# ------------------------------------------------------------------------------
include(cmake/tcm.cmake) # Automatically calls tcm_setup
tcm_setup_cache()
tcm_setup_cpm()
tcm_setup_project_version()
tcm_setup_docs()
#todo add examples path to doxygen ?

include(CTest)
enable_testing()
if(NOT EMSCRIPTEN)
    add_subdirectory(tests/simple)
    add_subdirectory(tests/shared_static)
    #include(tests/log.cmake) # Didn't find a suitable way to test log functionalities without having to modify tcm.cmake.
    add_subdirectory(tests/benchmark)
    add_subdirectory(tests/test)
    add_subdirectory(tests/examples)
    add_subdirectory(tests/ispc)
else ()
    add_subdirectory(tests/emscripten)
endif ()
