cmake_minimum_required(VERSION 3.30)
project(cmake_modules)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/../cmake")

include(tcm/include_all)

add_subdirectory(code-block)
