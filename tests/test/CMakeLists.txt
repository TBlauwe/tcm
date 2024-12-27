cmake_minimum_required(VERSION 3.25)

project(TEST_Catch2)

include(../../cmake/tcm.cmake)

tcm_tests(FILES test.cpp)
add_test(NAME Tests COMMAND tcm_tests)