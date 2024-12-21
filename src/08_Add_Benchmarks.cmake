# ------------------------------------------------------------------------------
# --- ADD BENCHMARKS
# ------------------------------------------------------------------------------
# Description:
#   Add benchmarks using google benchmark (with provided main).

# Usage :
#   tcm_add_benchmarks(TARGET your_target FILES your_source.cpp ...)
#
function(tcm_add_benchmarks)
    set(options)
    set(oneValueArgs
            TARGET
            GOOGLE_BENCHMARK_VERSION
    )
    set(multiValueArgs
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_section("BENCH")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(arg_GOOGLE_BENCHMARK_VERSION "v1.9.1")


    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    find_package(benchmark QUIET)
    if(NOT benchmark_FOUND OR benchmark_ADDED)
        CPMAddPackage(
                NAME benchmark
                GIT_TAG ${arg_GOOGLE_BENCHMARK_VERSION}
                GITHUB_REPOSITORY google/benchmark
                OPTIONS
                "BENCHMARK_ENABLE_INSTALL_DOCS OFF"
                "BENCHMARK_ENABLE_TESTING OFF"
                "BENCHMARK_INSTALL_DOCS OFF"
        )
        if(NOT benchmark_ADDED)
            tcm_warn("Couldn't found and install google benchmark (using CPM) --> Skipping benchmark.")
            return()
        endif ()
    endif()


    # ------------------------------------------------------------------------------
    # --- Target
    # ------------------------------------------------------------------------------
    add_executable(${arg_TARGET} ${arg_FILES})
    target_link_libraries(${arg_TARGET} PRIVATE benchmark::benchmark_main)
    set_target_properties(${arg_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}")

    # Copy google benchmark tools : compare.py and its requirements for ease of use
    add_custom_command(TARGET ${arg_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory
            "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
    )

    add_custom_command(TARGET ${arg_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${benchmark_SOURCE_DIR}/tools" "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
    )

    tcm_section_end()
endfunction()