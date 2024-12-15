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

# ------------------------------------------------------------------------------
# --- TESTS
# ------------------------------------------------------------------------------
include(cmake/tcm.cmake) # Automatically calls tcm_setup
tcm_setup_cache()
tcm_setup_cpm()
tcm_setup_project_version()
tcm_setup_docs()

include(CTest)
enable_testing()
#include(tests/log.cmake) # Didn't find a suitable way to test log functionalities without having to modify tcm.cmake.

# FFS I CAN'T MAKE IT WORK.
# CMake always fail to compile a simple C program.
# It works when project is build manually, but not through CTest
#add_test(NAME TEST_CodeBlocks
#        COMMAND ${CMAKE_CTEST_COMMAND}
#            --build-and-test ${CMAKE_SOURCE_DIR}/tests/code-block ${CMAKE_CURRENT_BINARY_DIR}/tests/code-block
#            --build-generator ${CMAKE_GENERATOR}
#            --build-makeprogram ${CMAKE_MAKE_PROGRAM}
#            --build-project TEST_CodeBlocks
#)
