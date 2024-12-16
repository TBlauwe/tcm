cmake_minimum_required(VERSION 3.25)

project(TEST_Simple)

include(../../cmake/tcm.cmake)

add_executable(simple main.cpp)
add_test(NAME Simple COMMAND simple)
