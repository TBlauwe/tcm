cmake_minimum_required(VERSION 3.25)

project(Benchmarking)

include(../../cmake/tcm.cmake)

tcm_benchmarks(FILES bench.cpp LIBRARIES MyLib)
add_test(NAME Benchmarking COMMAND ${PROJECT_NAME}_Benchmarks)
