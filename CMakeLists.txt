# ------------------------------------------------------------------------------
#           File : CMakeLists.txt
#         Author : TBlauwe
#    Description : Root CMakeLists.txt. Useful only for dev mode (to test tcm.cmake)
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.21)

project(TCM_TEST)

if(NOT PROJECT_IS_TOP_LEVEL)
    return() # If consumed, we should do nothing as this file is only for testing purposes
endif()

# ------------------------------------------------------------------------------
# --- TESTS
# ------------------------------------------------------------------------------
include(cmake/tcm.cmake) # Automatically calls tcm_setup
tcm_setup_cache()
tcm_setup_cpm()
tcm_setup_version()


include(tests/log.cmake)

