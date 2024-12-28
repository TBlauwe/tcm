cmake_minimum_required(VERSION 3.25)

project(TEST_Utility)

option(OPTION_A "A test option" ON)
option(OPTION_B "A test option" OFF)
option(OPTION_C "A test option" ON)

add_executable(test_utility main.cpp)


#-------------------------------------------------------------------------------
#   TEST: Target options
#
tcm_target_options(test_utility OPTIONS OPTION_A OPTION_B OPTION_C)
add_test(NAME Target_Options COMMAND $<TARGET_FILE:test_utility>)   # program returns 0 if defines are correctly set.

#-------------------------------------------------------------------------------
#   TEST : Assets copy
#
tcm_target_copy_assets(test_utility
        FILES copy_me_2.txt copy_me_3.txt
        FOLDERS assets/sub assets/sub_1 assets
)
add_test(NAME Copy_Assets
        COMMAND ${CMAKE_COMMAND} -D SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR} -D DEST_DIR=$<TARGET_FILE_DIR:test_utility> -P ${CMAKE_CURRENT_SOURCE_DIR}/test_tcm_target_copy_assets.cmake
)
