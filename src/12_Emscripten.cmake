# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   Set default flags for a minimal emscripten setup with some overridable options.
#
function(tcm_target_setup_for_emscripten target)
    set(options)
    set(oneValueArgs
            SHELL_FILE  # Override default shell file.
            ASSETS_DIR  # Specify a directory if you want to copy it alongside output.
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm__default_value(arg_SHELL_FILE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")

    if(NOT EMSCRIPTEN)
        return()
    endif ()

    set(CMAKE_EXECUTABLE_SUFFIX ".html" PARENT_SCOPE) # https://github.com/emscripten-core/emscripten/issues/18860
    target_link_options(${target} PRIVATE --shell-file ${arg_SHELL_FILE})
    target_link_options(${target} PRIVATE -sMAX_WEBGL_VERSION=2 -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=1mb)
    target_link_options(${target} PRIVATE -sEXPORTED_RUNTIME_METHODS=cwrap --no-heap-copy)
    target_link_options(${target} PRIVATE $<IF:$<CONFIG:DEBUG>,-sASSERTIONS=1,-sASSERTIONS=0> -sMALLOC=emmalloc)

    if(arg_ASSETS_DIR)
        target_link_options(${target} PRIVATE --preload-file ${arg_ASSETS_DIR}@$<TARGET_FILE_DIR:${target}>/assets)
        add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${target}>/assets
                COMMENT "Making directory $<TARGET_FILE_DIR:${target}>/assets/"
        )
        add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${arg_ASSETS_DIR}/assets $<TARGET_FILE_DIR:${target}>/assets
                COMMENT "Copying assets directory ${arg_ASSETS_DIR} to $<TARGET_FILE_DIR:${target}>/assets"
        )
    endif ()

endfunction()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Embed and setup a default html shell file for emscripten.
macro(tcm__setup_emscripten)
    file(WRITE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html.in" [=[@TCM_EMSCRIPTEN_SHELL_DEFAULT@]=])
    configure_file("${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html.in" "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html" @ONLY)
endmacro()
