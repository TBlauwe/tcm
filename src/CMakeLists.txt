# ------------------------------------------------------------------------------
#           File : src/CMakeLists.txt
#         Author : TBlauwe
#    Description : Generate `cmake/tcm.cmake` and `cmake/get_tcm.cmake`
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# --- Embedding
#
#   Some files are embedded in `tcm.cmake` to facilitate publication.
#   This function embed any file inside a variable, to re-generate it from CMake.
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
function(generate_mixin arg_FILE)
    cmake_path(REMOVE_EXTENSION arg_FILE OUTPUT_VARIABLE arg_FILE)
    cmake_path(GET arg_FILE FILENAME arg_FILE)
    set(mixin_file ${CMAKE_CURRENT_BINARY_DIR}/cmake/${arg_FILE}.cmake)
    configure_file(cmake/${arg_FILE}.cmake ${mixin_file} @ONLY)
    file(READ ${mixin_file} content)
    string(TOUPPER ${arg_FILE} arg_FILE)
    set(TCM_${arg_FILE}_MIXIN ${content} PARENT_SCOPE)
endfunction()

generate_mixin(cmake/asserts.cmake)
generate_mixin(cmake/benchmarks.cmake)
generate_mixin(cmake/closure.cmake)
generate_mixin(cmake/documentation.cmake)
generate_mixin(cmake/emscripten.cmake)
generate_mixin(cmake/examples.cmake)
generate_mixin(cmake/ispc.cmake)
generate_mixin(cmake/logging.cmake)
generate_mixin(cmake/options.cmake)
generate_mixin(cmake/shared_library.cmake)
generate_mixin(cmake/swig.cmake)
generate_mixin(cmake/tests.cmake)
generate_mixin(cmake/tools.cmake)
generate_mixin(cmake/utility.cmake)
generate_mixin(cmake/variables.cmake)
generate_mixin(cmake/version.cmake)

message(STATUS "Generating `cmake/tcm.cmake`")
configure_file(in/tcm.cmake.in ${PROJECT_SOURCE_DIR}/cmake/tcm.cmake @ONLY)

message(STATUS "Generating `cmake/get_tcm.cmake`")
configure_file(in/get_tcm.cmake.in ${PROJECT_SOURCE_DIR}/cmake/get_tcm.cmake @ONLY)

message(STATUS "Generating `README.me`")
configure_file(in/README.md.in ${PROJECT_SOURCE_DIR}/README.md @ONLY)
