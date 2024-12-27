# ------------------------------------------------------------------------------
# --- MODULE: BENCHMARKS
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Description:
#   Setup benchmarks using google benchmark (with provided main).
#
# Usage :
#   tcm_setup_benchmark([GOOGLE_BENCHMARK_VERSION vX.X.X])
#
function(tcm_setup_benchmark)
    set(oneValueArgs GOOGLE_BENCHMARK_VERSION)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm__default_value(arg_GOOGLE_BENCHMARK_VERSION "v1.9.1")

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
endfunction()


# ------------------------------------------------------------------------------
# Description:
#   Add benchmarks using google benchmark (with provided main).
#
# Usage :
#   tcm_benchmarks(TARGET your_target FILES your_source.cpp ...)
#
function(tcm_benchmarks)
    set(one_value_args NAME)
    set(multi_value_args FILES)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__default_value(arg_NAME "tcm_Benchmarks")

    tcm_setup_benchmark()

    if(NOT TARGET ${arg_NAME})
        add_executable(${arg_NAME} ${arg_FILES})
        target_link_libraries(${arg_NAME} PRIVATE benchmark::benchmark_main)
        set_target_properties(${arg_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}")
        # Copy google benchmark tools : compare.py and its requirements for ease of use
        add_custom_command(TARGET ${arg_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
                "${benchmark_SOURCE_DIR}/tools" "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
        )
    else ()
        target_sources(${arg_NAME} PRIVATE ${arg_FILES})
    endif ()

endfunction()
