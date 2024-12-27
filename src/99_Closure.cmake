# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------

function(tcm_setup)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    message("CLICOLOR: ${CLICOLOR}")
    message("CMAKE_COLOR_DIAGNOSTICS: ${CMAKE_COLOR_DIAGNOSTICS}")

    if(NOT TARGET TCM)          # A target cannot be defined more than once.
        add_custom_target(TCM)  # Utility target to store some internal settings.
    endif ()

    # We keep going even if setup was already called in some top projects.
    # Some setup functions could behave differently if it is the main project or not.
    # As TCM requires CMake > 3.21, we are sure that PROJECT_IS_TOP_LEVEL is defined.
    # It was added in 3.21 : https://cmake.org/cmake/help/latest/variable/PROJECT_IS_TOP_LEVEL.html.
    # TODO: May not be a good idea. include_guard() or not ?

    tcm__setup_logging()
    tcm__setup_variables()
    tcm_setup_cpm()
    tcm__setup_emscripten()
endfunction()
