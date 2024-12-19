# ------------------------------------------------------------------------------
# --- ISPC
# ------------------------------------------------------------------------------

function(tcm_target_setup_ispc)
    set(options)
    set(oneValueArgs
            HEADER_DIR
            HEADER_SUFFIX
            INSTRUCTION_SETS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(arg_HEADER_DIR)
        set_target_properties(ispc_lib PROPERTIES ISPC_HEADER_DIRECTORY ${arg_HEADER_DIR})
    endif ()
    if(arg_HEADER_SUFFIX)
        set_target_properties(ispc_lib PROPERTIES ISPC_HEADER_SUFFIX ${arg_HEADER_SUFFIX})
    endif ()
    if(arg_INSTRUCTION_SETS)
        set_target_properties(ispc_lib PROPERTIES ISPC_INSTRUCTION_SETS ${arg_INSTRUCTION_SETS})
    endif ()

    target_include_directories(ispc_lib PUBLIC $<TARGET_PROPERTY:ISPC_HEADER_DIRECTORY>)
endfunction()