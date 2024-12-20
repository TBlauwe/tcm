cmake_minimum_required(VERSION 3.25)

project(TEST_EMSCRIPTEN)

include(../../cmake/tcm.cmake)

add_executable(test_emscripten main.cpp)
tcm_target_setup_for_emscripten(test_emscripten)
set_target_properties(test_emscripten PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")

add_custom_target(open_html COMMAND emrun "${PROJECT_BINARY_DIR}/bin/test_emscripten.html")
add_dependencies(open_html test_emscripten)
