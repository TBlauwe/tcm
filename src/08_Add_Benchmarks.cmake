function(tcm_add_benchmarks)
    set(options)
    set(oneValueArgs
            TARGET
            GOOGLE_BENCHMARK_VERSION
    )
    set(multiValueArgs
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 TCM "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_begin_section("BENCH")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(TCM_GOOGLE_BENCHMARK_VERSION "v1.9.1")


    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    find_package(benchmark QUIET)
    if(NOT benchmark_FOUND OR benchmark_ADDED)
        CPMAddPackage(
                NAME benchmark
                GIT_TAG ${TCM_GOOGLE_BENCHMARK_VERSION}
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
    add_executable(${TCM_TARGET} ${TCM_FILES})
    target_link_libraries(${TCM_TARGET} PRIVATE benchmark::benchmark_main)
    set_target_properties(${TCM_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}")

    # Copy google benchmark tools : compare.py and its requirements for ease of use
    add_custom_command(TARGET ${TCM_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory
            "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
    )

    add_custom_command(TARGET ${TCM_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${benchmark_SOURCE_DIR}/tools" "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
    )

    tcm_end_section()
endfunction()