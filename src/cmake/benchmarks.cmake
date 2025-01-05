# ------------------------------------------------------------------------------
# --- MODULE: BENCHMARKS
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Description:
#   Setup benchmarks using google benchmark (with provided main).
#
function(tcm_setup_benchmark)
    set(oneValueArgs GOOGLE_BENCHMARK_VERSION)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_default_value(arg_GOOGLE_BENCHMARK_VERSION "v1.9.1")
    tcm_section("Benchmarks")

    find_package(benchmark QUIET)
    if(NOT benchmark_FOUND)
        tcm_silence_cpm_package(benchmark)
        CPMAddPackage(
                NAME benchmark
                GIT_TAG ${arg_GOOGLE_BENCHMARK_VERSION}
                GITHUB_REPOSITORY google/benchmark
                OPTIONS
                "BENCHMARK_ENABLE_INSTALL OFF"
                "BENCHMARK_ENABLE_INSTALL_DOCS OFF"
                "BENCHMARK_ENABLE_TESTING OFF"
                "BENCHMARK_INSTALL_DOCS OFF"
        )
        tcm_restore_message_log_level()
        if(NOT benchmark_SOURCE_DIR)
            tcm_warn("Couldn't find and install google benchmark (using CPM) --> Skipping benchmark.")
            return()
        endif ()
    endif()
endfunction()


# ------------------------------------------------------------------------------
# Description:
#   Add benchmarks using google benchmark (with provided main).
#
function(tcm_benchmarks)
    set(one_value_args
            NAME
    )
    set(multi_value_args
            FILES
            LIBRARIES
    )
    set(required_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "${multi_value_args}" "${required_args}")
    tcm_default_value(arg_NAME "${PROJECT_NAME}_Benchmarks")

    tcm_setup_benchmark()
    tcm_section("Benchmarks")
    if(NOT TARGET ${arg_NAME})
        tcm_log("Configuring ${arg_NAME}.")
        add_executable(${arg_NAME} ${arg_FILES})
        target_link_libraries(${arg_NAME} PRIVATE benchmark::benchmark_main ${arg_LIBRARIES})
        tcm_target_enable_optimisation_flags(${arg_NAME})
        set_target_properties(${arg_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/benchmarks")
        set_target_properties(${target_name} PROPERTIES FOLDER "Benchmarks")
        # Copy google benchmark tools : compare.py and its requirements for ease of use
        add_custom_command(
                TARGET ${arg_NAME}
                POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${benchmark_SOURCE_DIR}/tools" "$<TARGET_FILE_DIR:${arg_NAME}>/scripts/google_benchmark_tools"
                VERBATIM
        )
    else ()
        tcm_debug("Adding sources to ${arg_NAME}: ${arg_FILES}.")
        target_sources(${arg_NAME} PRIVATE ${arg_FILES})
    endif ()

endfunction()
