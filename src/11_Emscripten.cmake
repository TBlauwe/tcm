# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   Set default flags for a minimal emscripten setup with some overridable options.
#
function(tcm_target_setup_for_emscripten)
    if(NOT EMSCRIPTEN)
        return()
    endif ()

    set(one_value_args
            TARGET
            SHELL_FILE      # Override default shell file.
            PRELOAD_DIR     # Preload files inside directory.
            EMBED_DIR       # Embed files inside directory.
    )
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

    tcm__default_value(arg_SHELL_FILE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")
    tcm__emscripten_generate_default_shell_file()

    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    target_link_options(${arg_TARGET} PRIVATE --shell-file ${arg_SHELL_FILE})
    target_link_options(${arg_TARGET} PRIVATE -sMAX_WEBGL_VERSION=2 -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=1mb)
    target_link_options(${arg_TARGET} PRIVATE -sEXPORTED_RUNTIME_METHODS=cwrap --no-heap-copy)
    target_link_options(${arg_TARGET} PRIVATE $<IF:$<CONFIG:DEBUG>,-sASSERTIONS=1,-sASSERTIONS=0> -sMALLOC=emmalloc)

    add_custom_target(${arg_TARGET}_open_html COMMAND emrun $<TARGET_FILE:${arg_TARGET}>)
    add_dependencies(${arg_TARGET}_open_html ${arg_TARGET})

    # TODO Needs testing
    if(arg_PRELOAD_DIR)
        target_link_options(${arg_TARGET} PRIVATE --preload-file ${arg_PRELOAD_DIR})
    endif ()

    if(arg_EMBED_DIR)
        target_link_options(${arg_TARGET} PRIVATE --embed-file ${arg_PRELOAD_DIR})
    endif ()

endfunction()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Generate a default html shell file for emscripten.
#
function(tcm__emscripten_generate_default_shell_file)
    if(EMSCRIPTEN)
        set(embed_shell_file "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")
        if(NOT EXISTS ${embed_shell_file})
            tcm_info("(TCM) Generating embedded shell file for emscripten to ${embed_shell_file}.")
            file(WRITE "${embed_shell_file}.in" [=[@TCM_EMSCRIPTEN_SHELL_DEFAULT@]=])
        endif ()
        configure_file("${embed_shell_file}.in" ${embed_shell_file} @ONLY)
    endif ()
endfunction()

