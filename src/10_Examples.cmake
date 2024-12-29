# ------------------------------------------------------------------------------
# --- ADD EXAMPLES
# ------------------------------------------------------------------------------
# Description:
#   Convenience function to produce examples or a target for each source file (recursive).
#   You shouldn't use it for "complex" examples, where some .cpp files do not provide a main entry point.
#   There is not much to it. Here is what it does:
#       - Each example defines a new target, named : <relative_path_to_examples_folder>_filename
#       - Each example is a test (added to CTest)
#       - Each example executable is outputted to ${TCM_EXE_DIR}/examples.
#       - Each example can be added to a benchmark target with function option `WITH_BENCHMARK`.
#
# Parameters:
#   Take a folder path.
#
# Outputs:
#   ${TCM_EXAMPLE_TARGETS} - List of all examples target __configured during this call !__
#
# Usage :
#   tcm_examples(FOLDER examples/)
#
function(tcm_examples)
    set(options WITH_BENCHMARK)
    set(one_value_args
            FOLDER
            INTERFACE
    )
    set(multi_value_args)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")

    tcm_setup_test()
    if(arg_WITH_BENCHMARK)
        tcm_setup_benchmark()
        target_link_libraries(tcm_Benchmarks PUBLIC ${arg_INTERFACE})
    endif ()

    tcm_section("Examples")

    cmake_path(ABSOLUTE_PATH arg_FOLDER OUTPUT_VARIABLE arg_FOLDER NORMALIZE)
    file (GLOB_RECURSE examples CONFIGURE_DEPENDS RELATIVE ${arg_FOLDER} "${arg_FOLDER}/*.cpp" )

    tcm_log("Configuring examples:")
    tcm_indent()
    foreach (example IN LISTS examples)
        cmake_path(REMOVE_EXTENSION example OUTPUT_VARIABLE target_name)

        # Replace the slashes and dots with underscores to get a valid target name
        # (e.g. 'foo_bar_cpp' from 'foo/bar.cpp')
        string(REPLACE "/" "_" target_name ${target_name})

        add_executable(${target_name} ${arg_FOLDER}/${example})
        if(arg_INTERFACE)
            target_link_libraries(${target_name} PUBLIC ${arg_INTERFACE})
        endif ()
        set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/examples")
        set_target_properties(${target_name} PROPERTIES FOLDER "Examples")
        add_test(NAME ${target_name} COMMAND ${target_name})

        list(APPEND TARGETS ${target_name})

        if(NOT arg_WITH_BENCHMARK)
            tcm_log("- ${target_name}")
            continue()
        endif ()

        file(READ "${arg_FOLDER}/${example}" file_content)

        string(REGEX MATCH " main[(][)]" can_benchmark "${file_content}")

        if(NOT can_benchmark)
            tcm_warn("Example \"${example}\" cannot be integrated in a benchmark.")
            tcm_warn("Reason:  only empty `main()`signature is supported (and with a return value).")
            continue()
        endif ()

        string(REGEX REPLACE " main[(]" " ${target_name}_main(" file_content "${file_content}")

        # TODO I could check if a replaced happened and if yes, then we could generate one
        list(APPEND file_content "
#include <benchmark/benchmark.h>

static void BM_example_${target_name}(benchmark::State& state)
{
for (auto _: state)
    {
        ${target_name}_main();
    }
}

BENCHMARK(BM_example_${target_name});
"
        )
        set(benchmark_file ${CMAKE_CURRENT_BINARY_DIR}/benchmarks/${target_name}.cpp)
        file(WRITE ${benchmark_file} "${file_content}")
        tcm_benchmarks(FILES ${benchmark_file})

        tcm_log("* ${target_name} (w/ benchmark)")
    endforeach ()
    set(TCM_EXAMPLE_TARGETS ${TARGETS} PARENT_SCOPE)
endfunction()
