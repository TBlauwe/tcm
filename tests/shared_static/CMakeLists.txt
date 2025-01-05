cmake_minimum_required(VERSION 3.25)

project(TEST_Shared_Static VERSION 1.2.3)

include(../../cmake/tcm.cmake)

add_executable(test_shared main.cpp)
target_link_libraries(test_shared PRIVATE my_lib)
tcm_target_copy_dll(test_shared FROM my_lib)
#tcm_target_copy_required_dlls(test_shared FROM my_lib)
add_test(NAME Shared COMMAND test_shared)
