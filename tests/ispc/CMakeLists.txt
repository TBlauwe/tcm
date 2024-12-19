cmake_minimum_required(VERSION 3.25)

project(TEST_ISPC LANGUAGES C CXX ISPC)

include(../../cmake/tcm.cmake)

add_library(ispc_lib STATIC simple.ispc)
tcm_target_setup_ispc(ispc_lib)

add_executable(test_ispc main.cpp)
target_link_libraries(test_ispc PRIVATE ispc_lib)
add_test(NAME TEST_ISPC COMMAND test_ispc)