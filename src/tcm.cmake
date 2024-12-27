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
#   For more details about a mixin, see related cmake file.
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.26) # Required for `copy_directory_if_different`.

@TCM_OPTIONS_MIXIN@

@TCM_LOGGING_MIXIN@

@TCM_UTILITY_MIXIN@

@TCM_VARIABLES_MIXIN@

@TCM_SHARED_MIXIN@

@TCM_CPM_MIXIN@

@TCM_CACHE_MIXIN@

@TCM_VERSION_MIXIN@

@TCM_BENCHMARKS_MIXIN@

@TCM_TESTS_MIXIN@

@TCM_EXAMPLES_MIXIN@

@TCM_ISPC_MIXIN@

@TCM_EMSCRIPTEN_MIXIN@

@TCM_DOCS_MIXIN@

@TCM_CLOSURE_MIXIN@
