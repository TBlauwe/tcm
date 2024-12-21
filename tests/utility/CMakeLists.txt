cmake_minimum_required(VERSION 3.25)

project(TEST_Utility)

tcm_setup()

option(OPTION_A "A test option" ON)
option(OPTION_B "A test option" OFF)
option(OPTION_C "A test option" ON)

add_executable(test_utility main.cpp)


#-------------------------------------------------------------------------------
#   TEST: Target options
#
tcm_target_options(test_utility OPTIONS OPTION_A OPTION_B OPTION_C)

get_target_property(definitions test_utility COMPILE_DEFINITIONS)
if(
                ("OPTION_A" IN_LIST definitions)
        AND NOT ("OPTION_B" IN_LIST definitions)
        AND     ("OPTION_C" IN_LIST definitions)
)
    add_test(Target_Options COMMAND true)
else ()
    add_test(Target_Options COMMAND false)
endif ()

#-------------------------------------------------------------------------------
#   TEST : Assets copy
#
tcm_target_assets(test_utility SOURCE assets)
