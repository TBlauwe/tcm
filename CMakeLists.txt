# ------------------------------------------------------------------------------
#           File : CMakeLists.txt
#         Author : TBlauwe
#    Description : Root CMakeLists.txt. Useful only for dev mode (to test tcm.cmake)
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.21)

project(TCM_TEST)

if(NOT PROJECT_IS_TOP_LEVEL)
    return() # If consumed, we should do nothing as this file is only for testing purposes
endif()

# ------------------------------------------------------------------------------
# --- TESTS
# ------------------------------------------------------------------------------
include(cmake/tcm.cmake) # Automatically calls tcm_setup
#tcm_setup()
tcm_setup_version()
tcm_setup_cache()


# ------------------------------------------------------------------------------
# --- LOGGING TESTS
# ------------------------------------------------------------------------------
tcm_begin_section("LOGGING")
    #tcm_error("Error message" FATAL) # For FATAL Error
    tcm_error("Expected error message.")
    tcm_warn("Expected warning message.")
    tcm_info("An info message.")
    tcm_log("A normal message.")
    tcm_debug("YOU SHOULD NOT SEE THIS.")
    tcm_trace("YOU SHOULD NOT SEE THIS.")
    tcm_empty_line()
    block()
        project(NEST_PROJECT)
        tcm_setup()
        tcm_log("Test with a nested project.")
        tcm_begin_section("TEST")
            tcm_log("Should be nested in its own scope.")
        tcm_end_section()
    endblock()
    block()
        project(NONE_VERBOSE)
        set(TCM_VERBOSE FALSE)
        tcm_setup()
        tcm_error("SHOULD NOT BE DISPLAYED")
        tcm_begin_section("ERROR")
            tcm_error("SHOULD NOT BE DISPLAYED")
        tcm_end_section()
    endblock()
    tcm_empty_line()
    tcm_begin_section("TRACE LEVEL")
        set(CMAKE_MESSAGE_LOG_LEVEL TRACE)
        tcm_log("Now debug and trace should be displayed.")
        tcm_debug("Debug message.")
        tcm_trace("Trace message.")
    tcm_end_section()
    tcm_empty_line()
    tcm_begin_section("INDENTING")
        tcm_log("Indent level 0.")
        tcm_indent()
            tcm_log("Indent level 1.")
            tcm_indent()
                tcm_log("Indent level 2.")
            tcm_outdent()
            tcm_log("Outdent to level 1.")
        tcm_outdent()
        tcm_log("Outdent to level 0.")
    tcm_end_section()
    tcm_empty_line()
    tcm_begin_section("CHECK SECTION")
        tcm_check_start("Looking for nothing 1.")
        tcm_check_fail("Failed for no reason")
        tcm_check_start("Looking for nothing 2.")
        tcm_check_pass("Pass for no reason")
        tcm_check_start("Looking for nothing 3.")
            tcm_check_start("Looking for nothing 4.")
            tcm_check_fail("Failed for no reason")
            tcm_check_start("Looking for nothing 5.")
            tcm_check_pass("Pass for no reason")
        tcm_check_pass("Pass for no reason")
    tcm_end_section()
    tcm_empty_line()
    tcm_info("Done.")
tcm_end_section()

