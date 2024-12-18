cmake_minimum_required(VERSION 3.25)

project(TEST_Examples LANGUAGES C)

# Create a simple library
add_library(MyLib my_lib/my_lib.c)
target_include_directories(MyLib PUBLIC my_lib)

# Create an interface target so examples and benchmark can inherit from it.
add_library(ExampleInterface INTERFACE)
target_link_libraries(ExampleInterface INTERFACE MyLib)

tcm_add_examples(FOLDER examples WITH_BENCHMARK INTERFACE ExampleInterface)
