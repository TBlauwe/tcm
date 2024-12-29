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

    set(options)
    set(oneValueArgs
            TARGET
            SHELL_FILE  # Override default shell file.
            ASSETS_DIR  # Specify a directory if you want to copy it alongside output.
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm__ensure_target()

    if(NOT arg_SHELL_FILE)
        tcm__emscripten_generate_default_shell_file()
        tcm__default_value(arg_SHELL_FILE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")
    endif ()

    target_link_options(${arg_TARGET} PRIVATE --shell-file ${arg_SHELL_FILE})
    target_link_options(${arg_TARGET} PRIVATE -sMAX_WEBGL_VERSION=2 -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=1mb)
    target_link_options(${arg_TARGET} PRIVATE -sEXPORTED_RUNTIME_METHODS=cwrap --no-heap-copy)
    target_link_options(${arg_TARGET} PRIVATE $<IF:$<CONFIG:DEBUG>,-sASSERTIONS=1,-sASSERTIONS=0> -sMALLOC=emmalloc)

    add_custom_target(${arg_TARGET}_open_html COMMAND emrun $<TARGET_FILE:${arg_TARGET}>)
    add_dependencies(${arg_TARGET}_open_html ${arg_TARGET})

    # TODO Reuse utility functions
    if(arg_ASSETS_DIR)
        target_link_options(${arg_TARGET} PRIVATE --preload-file ${arg_ASSETS_DIR}@$<TARGET_FILE_DIR:${arg_TARGET}>/assets)
        add_custom_command(TARGET ${arg_TARGET} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${arg_TARGET}>/assets
                COMMENT "Making directory $<TARGET_FILE_DIR:${arg_TARGET}>/assets/"
        )
        add_custom_command(TARGET ${arg_TARGET} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${arg_ASSETS_DIR}/assets $<TARGET_FILE_DIR:${arg_TARGET}>/assets
                COMMENT "Copying assets directory ${arg_ASSETS_DIR} to $<TARGET_FILE_DIR:${arg_TARGET}>/assets"
        )
    endif ()

endfunction()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Generate a default html shell file for emscripten.
macro(tcm__emscripten_generate_default_shell_file)
    if(EMSCRIPTEN)
        set(embed_shell_file "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")
        if(NOT EXISTS ${embed_shell_file})
            tcm_info("(TCM) Generating embedded shell file for emscripten to ${embed_shell_file}.")
            file(WRITE "${embed_shell_file}.in" [=[@TCM_EMSCRIPTEN_SHELL_DEFAULT@]=])
        endif ()
        configure_file("${embed_shell_file}.in" ${embed_shell_file} @ONLY)
    endif ()
endmacro()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Set CMAKE_EXECUTABLE_SUFFIX to ".html" to let emscripten also produce an .html file.
macro(tcm__module_emscripten)
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
endmacro()
