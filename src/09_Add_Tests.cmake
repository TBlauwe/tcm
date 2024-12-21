# ------------------------------------------------------------------------------
# --- ADD TESTS
# ------------------------------------------------------------------------------
# Description:
#   Add tests using Catch2 (with provided main).
#
# Usage :
#   tcm_add_benchmarks(TARGET your_target FILES your_source.cpp ...)
#
function(tcm_add_tests)
    set(options)
    set(oneValueArgs
            TARGET
            CATCH2_VERSION
    )
    set(multiValueArgs
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_section("TESTS")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(arg_CATCH2_VERSION "v3.7.1")


    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    find_package(Catch2 3 QUIET)

    if(NOT Catch2_FOUND OR Catch2_ADDED)
        CPMAddPackage(
                NAME Catch2
                GIT_TAG ${arg_CATCH2_VERSION}
                GITHUB_REPOSITORY catchorg/Catch2
        )
        if(NOT Catch2_ADDED)
            tcm_warn("Couldn't found and install Catch2 (using CPM) --> Skipping tests.")
            return()
        endif ()
    endif()


    # ------------------------------------------------------------------------------
    # --- Target
    # ------------------------------------------------------------------------------
    add_executable(${arg_TARGET} ${arg_FILES})
    target_link_libraries(${arg_TARGET} PRIVATE Catch2::Catch2WithMain)
    set_target_properties(${arg_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}")

    list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)
    include(Catch)
    catch_discover_tests(${arg_TARGET})

    tcm_section_end()
endfunction()