# ------------------------------------------------------------------------------
#           File : CMakeLists.txt
#         Author : TBlauwe
#    Description : Root CMakeLists.txt.
#
#   /!\ Project should not be consumed /!\
#   It won't do / break anything, but there is no reason to.
#   It's role is to generate `tcm.cmake` and test it.
#   Just include `cmake/tcm.cmake`.
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.26)

project(TCM
        DESCRIPTION "A CMake module to share several functionalities used across C / C++ projects."
        HOMEPAGE_URL "https://github.com/TBlauwe/tcm"
        VERSION 0.5.0
)

# Guard against consumption.
if(NOT PROJECT_IS_TOP_LEVEL)
    return()
endif()


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
    configure_file(src/${arg_MIXIN}.cmake ${mixin_file} @ONLY)
    file(READ ${mixin_file} content)
    set(${arg_VAR} ${content} PARENT_SCOPE)
endfunction()

generate_mixin(00_Options               TCM_OPTIONS_MIXIN)
generate_mixin(01_Logging               TCM_LOGGING_MIXIN)
generate_mixin(02_Utility               TCM_UTILITY_MIXIN)
generate_mixin(03_Variables             TCM_VARIABLES_MIXIN)
generate_mixin(04_Shared                TCM_SHARED_MIXIN)
generate_mixin(05_CPM                   TCM_CPM_MIXIN)
generate_mixin(06_Cache                 TCM_CACHE_MIXIN)
generate_mixin(07_Version               TCM_VERSION_MIXIN)
generate_mixin(08_Benchmarks            TCM_BENCHMARKS_MIXIN)
generate_mixin(09_Tests                 TCM_TESTS_MIXIN)
generate_mixin(10_Examples              TCM_EXAMPLES_MIXIN)
generate_mixin(11_ISPC                  TCM_ISPC_MIXIN)
generate_mixin(12_Emscripten            TCM_EMSCRIPTEN_MIXIN)
generate_mixin(98_Docs                  TCM_DOCS_MIXIN)
generate_mixin(99_Closure               TCM_CLOSURE_MIXIN)

message(STATUS "Generating `cmake/tcm.cmake`")
configure_file(src/in/tcm.cmake.in ${PROJECT_SOURCE_DIR}/cmake/tcm.cmake @ONLY)

message(STATUS "Generating `cmake/get_tcm.cmake`")
configure_file(src/in/get_tcm.cmake.in ${PROJECT_SOURCE_DIR}/cmake/get_tcm.cmake @ONLY)

message(STATUS "Generating `README.me`")
configure_file(src/in/README.md.in ${PROJECT_SOURCE_DIR}/README.md @ONLY)


# ------------------------------------------------------------------------------
# --- Some maintenance
# ------------------------------------------------------------------------------
include(cmake/tcm.cmake)
tcm_setup_cache()
tcm_setup_cpm()
#tcm_setup_project_version()
tcm_setup_docs()
#todo add examples path to doxygen ?

# ------------------------------------------------------------------------------
# --- TESTS
# ------------------------------------------------------------------------------

enable_testing()
if(NOT EMSCRIPTEN)
    add_subdirectory(tests/simple)
    add_subdirectory(tests/shared_static)
    add_test(NAME Logging COMMAND ${CMAKE_COMMAND} -B ${CMAKE_CURRENT_BINARY_DIR}/tests/logging -S ${CMAKE_CURRENT_SOURCE_DIR}/tests/logging)
    add_subdirectory(tests/utility)
    add_subdirectory(tests/benchmark)
    add_subdirectory(tests/test)
    add_subdirectory(tests/examples)
    add_subdirectory(tests/ispc)
else()
    add_subdirectory(tests/emscripten)
endif ()
