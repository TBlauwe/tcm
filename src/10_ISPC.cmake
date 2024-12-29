# ------------------------------------------------------------------------------
# --- ISPC
# ------------------------------------------------------------------------------

function(tcm_target_setup_ispc target)
    set(options)
    set(oneValueArgs
            HEADER_DIR
            HEADER_SUFFIX
            INSTRUCTION_SETS
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm__default_value(arg_HEADER_DIR "${CMAKE_CURRENT_BINARY_DIR}/ispc/")
    tcm__default_value(arg_HEADER_SUFFIX ".h")

    set_target_properties(ispc_lib PROPERTIES ISPC_HEADER_DIRECTORY ${arg_HEADER_DIR})
    set_target_properties(ispc_lib PROPERTIES ISPC_HEADER_SUFFIX ${arg_HEADER_SUFFIX})

    if(arg_INSTRUCTION_SETS)
        set_target_properties(ispc_lib PROPERTIES ISPC_INSTRUCTION_SETS ${arg_INSTRUCTION_SETS})
    endif ()

    target_include_directories(ispc_lib PUBLIC $<TARGET_PROPERTY:ISPC_HEADER_DIRECTORY>)
endfunction()