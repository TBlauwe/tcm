function(generate_mixin _mixin _output_var)
    set(GEN_FILE ${CMAKE_CURRENT_BINARY_DIR}/cmake/${_mixin}.cmake)
    configure_file(${_mixin}.cmake ${GEN_FILE} @ONLY)
    file(READ ${GEN_FILE} FILE_OUTPUT)
    set(${_output_var} ${FILE_OUTPUT} PARENT_SCOPE)
endfunction()

# Take care ! If you use this variable to embed a file in a cmake file, make sure to use bracket syntax.
# e.g. file(WRITE my_file [=[@_output_var@]=]
# Otherwise you may have problem with quotes.
# If you think about escaping quotes, beware if there are ";" in your string as they will also be removed. (bc lists !)
function(embed_file _file _output_var)
    file(READ ${_file} FILE_CONTENT)
    set(${_output_var} ${FILE_CONTENT} PARENT_SCOPE)
endfunction()

embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/header.html       TCM_DOXYGEN_HTML_HEADER_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/footer.html       TCM_DOXYGEN_HTML_FOOTER_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/custom.css        TCM_DOXYGEN_HTML_EXTRA_STYLESHEET_DEFAULT)
embed_file(${PROJECT_SOURCE_DIR}/docs/doxygen/DoxygenLayout.xml TCM_DOXYGEN_LAYOUT_FILE_DEFAULT)

generate_mixin(00_Options               TCM_OPTIONS_MIXIN)
generate_mixin(01_Logging               TCM_LOGGING_MIXIN)
generate_mixin(02_Utility               TCM_UTILITY_MIXIN)
generate_mixin(03_Variables             TCM_VARIABLES_MIXIN)
generate_mixin(04_Shared                TCM_SHARED_MIXIN)
generate_mixin(05_CPM                   TCM_CPM_MIXIN)
generate_mixin(06_Setup_Cache           TCM_SETUP_CACHE_MIXIN)
generate_mixin(07_Setup_Project_Version TCM_SETUP_PROJECT_VERSION_MIXIN)
generate_mixin(08_Add_Benchmarks        TCM_ADD_BENCHMARKS_MIXIN)
generate_mixin(09_Add_Tests             TCM_ADD_TESTS_MIXIN)
generate_mixin(10_Add_Examples          TCM_ADD_EXAMPLES_MIXIN)
generate_mixin(11_ISPC                  TCM_ISPC_MIXIN)
generate_mixin(98_Setup_Docs            TCM_SETUP_DOCS_MIXIN)
generate_mixin(99_Closure               TCM_CLOSURE_MIXIN)

configure_file(tcm.cmake ${PROJECT_SOURCE_DIR}/cmake/tcm.cmake)
