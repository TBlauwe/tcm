# ------------------------------------------------------------------------------
#           File : src/CMakeLists.txt
#         Author : TBlauwe
#    Description : Generate `cmake/tcm.cmake` and `cmake/get_tcm.cmake`
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# --- Embedding
#   Some files are embedded in `tcm.cmake` to facilitate publication.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#   Embed any file inside a variable, to re-generate it from CMake.
#   ```cmake
#   file(WRITE my_file [=[@_output_var@]=]
#   ```
#   It is recommended to use bracket syntax, to prevent problems with semi-colons and quotes.
#
function(embed_file _file _output_var)
    file(READ ${_file} FILE_CONTENT)
    set(${_output_var} ${FILE_CONTENT} PARENT_SCOPE)
endfunction()

embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/header.html       TCM_DOXYGEN_HTML_HEADER_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/footer.html       TCM_DOXYGEN_HTML_FOOTER_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/custom.css        TCM_DOXYGEN_HTML_EXTRA_STYLESHEET_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/DoxygenLayout.xml TCM_DOXYGEN_LAYOUT_FILE_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/assets/shell_minimal.html      TCM_EMSCRIPTEN_SHELL_DEFAULT)


# ------------------------------------------------------------------------------
# --- Generation
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#   Produce a variable with the contents of a CMake file.
#
function(generate_mixin arg_MIXIN arg_VAR)
    set(mixin_file ${CMAKE_CURRENT_BINARY_DIR}/cmake/${arg_MIXIN}.cmake)
    configure_file(${arg_MIXIN}.cmake ${mixin_file} @ONLY)
    file(READ ${mixin_file} content)
    set(${arg_VAR} ${content} PARENT_SCOPE)
endfunction()

generate_mixin(00_Options               TCM_OPTIONS_MIXIN)
generate_mixin(01_Logging               TCM_LOGGING_MIXIN)
generate_mixin(02_Utility               TCM_UTILITY_MIXIN)
generate_mixin(03_Variables             TCM_VARIABLES_MIXIN)
generate_mixin(04_Shared                TCM_SHARED_MIXIN)
generate_mixin(05_Tools                 TCM_TOOLS_MIXIN)
generate_mixin(06_Version               TCM_VERSION_MIXIN)
generate_mixin(07_Benchmarks            TCM_BENCHMARKS_MIXIN)
generate_mixin(08_Tests                 TCM_TESTS_MIXIN)
generate_mixin(09_Examples              TCM_EXAMPLES_MIXIN)
generate_mixin(10_ISPC                  TCM_ISPC_MIXIN)
generate_mixin(11_Emscripten            TCM_EMSCRIPTEN_MIXIN)
generate_mixin(98_Docs                  TCM_DOCS_MIXIN)
generate_mixin(99_Closure               TCM_CLOSURE_MIXIN)

message(STATUS "Generating `cmake/tcm.cmake`")
configure_file(in/tcm.cmake.in ${PROJECT_SOURCE_DIR}/cmake/tcm.cmake @ONLY)

message(STATUS "Generating `cmake/get_tcm.cmake`")
configure_file(in/get_tcm.cmake.in ${PROJECT_SOURCE_DIR}/cmake/get_tcm.cmake @ONLY)

message(STATUS "Generating `README.me`")
configure_file(in/README.md.in ${PROJECT_SOURCE_DIR}/README.md @ONLY)
