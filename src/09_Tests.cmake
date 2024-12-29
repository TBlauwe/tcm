# ------------------------------------------------------------------------------
# --- MODULE: TESTS
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Description:
#   Setup tests using Catch2 (with provided main).
#
# Usage :
#   tcm_setup_test([CATCH2_VERSION vX.X.X])
#
function(tcm_setup_test)
    set(oneValueArgs CATCH2_VERSION)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm__default_value(arg_CATCH2_VERSION "v3.7.1")

    tcm_section("Tests")

    find_package(Catch2 3 QUIET)
    if(NOT Catch2_FOUND OR Catch2_ADDED)
        tcm_check_start("Setup ...")
        CPMAddPackage(
                NAME Catch2
                GIT_TAG ${arg_CATCH2_VERSION}
                GITHUB_REPOSITORY catchorg/Catch2
        )
        if(NOT Catch2_ADDED)
            tcm_check_fail("failed. Couldn't found and install Catch2 (using CPM) --> Skipping tests.")
            return()
        endif ()
        list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)
        include(Catch)
        tcm_check_pass("done.")
    endif()
endfunction()


# ------------------------------------------------------------------------------
# Description:
#   Add tests using Catch2 (with provided main).
#
# Usage :
#   tcm_tests([NAME <name>] FILES your_source.cpp ...)
#
function(tcm_tests)
    set(one_value_args NAME)
    set(multi_value_args FILES)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__default_value(arg_NAME "tcm_Tests")

    tcm_setup_test()
    if(NOT TARGET ${arg_NAME})
        add_executable(${arg_NAME} ${arg_FILES})
        target_link_libraries(${arg_NAME} PRIVATE Catch2::Catch2WithMain)
        set_target_properties(${arg_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/tests")
        set_target_properties(${target_name} PROPERTIES FOLDER "Tests")
        catch_discover_tests(${arg_NAME})
    else ()
        target_sources(${arg_NAME} PRIVATE ${arg_FILES})
    endif ()

endfunction()