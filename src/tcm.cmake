# ------------------------------------------------------------------------------
# File:
#   tcm.cmake
#
# Author:
#   TBlauwe
#
# Description:
#   Opinionated CMake module to share and manage common functionality and settings for C++ / C project.
#   Functions and macros are all prefixed with tcm_.
#   Private functions and macros are all prefixed with tcm__ (double underscore).
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.25) # Required for `SOURCE_FROM_CONTENT` : https://cmake.org/cmake/help/latest/command/try_compile.html

@TCM_OPTIONS_MIXIN@

@TCM_LOGGING_MIXIN@

@TCM_UTILITY_MIXIN@

@TCM_VARIABLES_MIXIN@

@TCM_CPM_MIXIN@

@TCM_SETUP_CACHE_MIXIN@

@TCM_SETUP_PROJECT_VERSION_MIXIN@

@TCM_ADD_BENCHMARKS_MIXIN@

@TCM_ADD_TESTS_MIXIN@

@TCM_ADD_EXAMPLES_MIXIN@

@TCM_SETUP_DOCS_MIXIN@

@TCM_CLOSURE_MIXIN@
