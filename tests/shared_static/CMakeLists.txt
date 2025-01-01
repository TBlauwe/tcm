cmake_minimum_required(VERSION 3.25)

project(TEST_Shared_Static VERSION 1.2.3)

include(../../cmake/tcm.cmake)

set(BUILD_SHARED_LIBS ON)

add_library(my_lib my_lib/my_lib.c)
target_include_directories(my_lib PUBLIC my_lib)
tcm_target_export_header(my_lib)

add_executable(test_shared main.cpp)
target_link_libraries(test_shared PRIVATE my_lib)
add_test(NAME Shared COMMAND test_shared)
