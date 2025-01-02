cmake_minimum_required(VERSION 3.25)

include(CheckLanguage)
check_language(ISPC)
if(NOT CMAKE_ISPC_COMPILER)
    tcm_warn("CMake compiler not supported --> Skipping.")
    return()
endif ()

project(TEST_ISPC LANGUAGES C CXX ISPC)

include(../../cmake/tcm.cmake)

add_library(ispc_lib STATIC simple.ispc)
tcm_target_setup_ispc(ispc_lib)

add_executable(test_ispc main.cpp)
target_link_libraries(test_ispc PRIVATE ispc_lib)
add_test(NAME ISPC COMMAND test_ispc)