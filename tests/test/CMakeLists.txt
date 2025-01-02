cmake_minimum_required(VERSION 3.25)

project(Tests)

include(../../cmake/tcm.cmake)

tcm_tests(FILES test.cpp)
add_test(NAME Tests COMMAND ${PROJECT_NAME}_Tests)