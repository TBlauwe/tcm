cmake_minimum_required(VERSION 3.26)

project(TEST_Logging)

set(TCM_DOWNLOAD_VERSION 1.0.0)
include(../../cmake/get_tcm.cmake)

#tcm_fatal_error("Error message")
tcm_error("Expected error message.")
tcm_warn("Expected warning message.")
#tcm_author_warn("Expected author warning message.")
tcm_info("An info message.")
tcm_log("A normal message.")
tcm_debug("YOU SHOULD NOT SEE THIS.")
tcm_trace("YOU SHOULD NOT SEE THIS.")
tcm_check_start("Start a section")
    tcm_check_start("Should ...")
    tcm_check_fail("fail.")
tcm_check_pass("done.")

tcm_section("SECTION")
    tcm_info("An info message.")
    tcm_section("TRACE_LEVEL")
        set(CMAKE_MESSAGE_LOG_LEVEL TRACE)
        tcm_log("Setting CMAKE_MESSAGE_LOG_LEVEL to TRACE")
        tcm_debug("A debug message.")
        tcm_trace("A trace message.")
    tcm_section_end()
# tcm_section_end() # OPTIONAL - Scoping rule will take care of this.
