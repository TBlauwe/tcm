cmake_minimum_required(VERSION 3.26)

project(TEST_Arguments)

include(../../cmake/tcm.cmake)

function(test_func)
    set(options             FLAG)
    set(one_value_args      A B )
    set(multi_value_args    ARGS)
    set(required_args       A B ARGS)
    tcm_function_parse_arguments()
endfunction()


test_func(A test B test ARGS)
#test_target_func()
#test_target_func(not_a_target)
