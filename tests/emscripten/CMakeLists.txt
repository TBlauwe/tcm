cmake_minimum_required(VERSION 3.25)

project(Emscripten)

include(../../cmake/tcm.cmake)

add_executable(emscripten main.cpp)
tcm_target_setup_for_emscripten(emscripten)
