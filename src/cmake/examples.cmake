# ------------------------------------------------------------------------------
# --- EXAMPLES
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#   FOR INTERNAL USAGE: used by `tcm_examples`
#
function(tcm__add_example arg_FILE arg_NAME)
    cmake_path(REMOVE_EXTENSION arg_NAME OUTPUT_VARIABLE target_name)

    # Replace the slashes and dots with underscores to get a valid target name
    # (e.g. 'foo_bar_cpp' from 'foo/bar.cpp')
    string(REPLACE "/" "_" target_name ${target_name})

    add_executable(${target_name} ${arg_FILE})
    if(arg_LIBRARIES)
        target_link_libraries(${target_name} PUBLIC ${arg_LIBRARIES})
    endif ()
    set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/examples")
    set_target_properties(${target_name} PROPERTIES FOLDER "Examples")
    add_test(NAME ${target_name} COMMAND ${target_name})

    list(APPEND TARGETS ${target_name})
    set(TARGETS ${TARGETS} PARENT_SCOPE)

    if(NOT arg_WITH_BENCHMARK)
        tcm_log("Configuring example \"${target_name}\"")
        return()
    endif ()

    set(benchmark_file ${CMAKE_CURRENT_BINARY_DIR}/benchmarks/${target_name}.cpp)
    if(${arg_FILE} IS_NEWER_THAN ${benchmark_file})

        file(READ "${arg_FILE}" file_content)

        if(NOT file_content)
            tcm_warn("Example \"${arg_NAME}\" cannot be integrated in a benchmark.")
            tcm_warn("Reason:  could not read file ${arg_FILE}.")
            return()
        endif ()

        string(REGEX MATCH " main[(][)]" can_benchmark "${file_content}")

        if(NOT can_benchmark)
            tcm_warn("Example \"${arg_NAME}\" cannot be integrated in a benchmark.")
            tcm_warn("Reason:  only empty `main()`signature is supported (and with a return value).")
            return()
        endif ()

        string(REGEX REPLACE " main[(]" " ${target_name}_main(" file_content "${file_content}")

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
        tcm_info("Generating benchmark source file for ${target_name}: ${benchmark_file}")
        file(WRITE ${benchmark_file} "${file_content}")
    endif ()
    if(arg_LIBRARIES)
        tcm_benchmarks(FILES ${benchmark_file} LIBRARIES ${arg_LIBRARIES})
    else ()
        tcm_benchmarks(FILES ${benchmark_file})
    endif ()

    tcm_log("Configuring example \"${target_name}\" (w/ benchmark)")
endfunction()


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
function(tcm_examples)
    set(options
            WITH_BENCHMARK
    )
    set(one_value_args
            FILES
    )
    set(multi_value_args
            LIBRARIES
    )
    set(required_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "${options}" "${one_value_args}" "${multi_value_args}" "${required_args}")

    tcm_setup_test()
    if(arg_WITH_BENCHMARK)
        tcm_setup_benchmark()
    endif ()

    tcm_section("Examples")

    foreach (item IN LISTS arg_FILES)
        file(REAL_PATH ${item} path)
        if(IS_DIRECTORY ${path})
            list(APPEND folders ${path})
        else ()
            list(APPEND ${item})
        endif ()
    endforeach ()

    foreach (folder IN LISTS folders)
        file (GLOB_RECURSE examples CONFIGURE_DEPENDS RELATIVE ${folder} "${folder}/*.cpp" )
        list(APPEND DOXYGEN_EXAMPLE_PATH ${folder})
        foreach (example IN LISTS examples)
            tcm__add_example(${folder}/${example} ${example})
        endforeach ()
    endforeach ()

    foreach (example IN LISTS files)
        file(REAL_PATH ${example} path)
        list(APPEND DOXYGEN_EXAMPLE_PATH ${path})
        tcm__add_example(${path} ${example})
    endforeach ()

    set(TCM_EXAMPLE_TARGETS ${TARGETS} PARENT_SCOPE)
    set(DOXYGEN_EXAMPLE_PATH ${DOXYGEN_EXAMPLE_PATH} PARENT_SCOPE)
endfunction()
