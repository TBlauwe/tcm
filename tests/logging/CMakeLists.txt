project(TEST_Logging)

include(../../cmake/tcm.cmake)

#tcm_error("Error message" FATAL) # For FATAL Error
tcm_error("Expected error message.")
tcm_warn("Expected warning message.")
tcm_info("An info message.")
tcm_log("A normal message.")
tcm_debug("YOU SHOULD NOT SEE THIS.")
tcm_trace("YOU SHOULD NOT SEE THIS.")

tcm_section("SECTION")
    tcm_info("An info message.")
    tcm_section("TRACE_LEVEL")
        set(CMAKE_MESSAGE_LOG_LEVEL TRACE)
        tcm_log("Setting CMAKE_MESSAGE_LOG_LEVEL to TRACE")
        tcm_debug("A debug message.")
        tcm_trace("A trace message.")
    tcm_section_end()
# tcm_section_end() # OPTIONAL - Scoping rule will take care of this.
