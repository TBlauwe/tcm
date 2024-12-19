cmake_minimum_required(VERSION 3.25)

project(TEST_Catch2)

include(../../cmake/tcm.cmake)

tcm_add_tests(TARGET test_catch2 FILES test.cpp)
add_test(NAME Catch2 COMMAND test_catch2)