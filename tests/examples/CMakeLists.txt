cmake_minimum_required(VERSION 3.25)

project(Examples LANGUAGES C CXX)

include(../../cmake/tcm.cmake)

tcm_examples(FILES examples WITH_BENCHMARK LIBRARIES my_lib_static)
