cmake_minimum_required(VERSION 3.25)

project(TEST_GBench)

include(../../cmake/tcm.cmake)

tcm_add_benchmarks(TARGET test_gbench FILES bench.cpp)
add_test(NAME GBench COMMAND test_gbench)