# ------------------------------------------------------------------------------
# --- LOGGING
# ------------------------------------------------------------------------------
# This module defines functions/macros for logging purposes in CMake.
# They are simple wrappers over `message()`, whom are mostly noop when current project is not top level.

#-------------------------------------------------------------------------------
#   Indent cmake message.
#
macro(tcm_indent)
    list(APPEND CMAKE_MESSAGE_INDENT "    ")
endmacro()

#-------------------------------------------------------------------------------
#   Outdent cmake messages.
#
macro(tcm_outdent)
    list(POP_BACK CMAKE_MESSAGE_INDENT)
endmacro()

#-------------------------------------------------------------------------------
#   Print an empty line.
#
function(tcm_empty_line)
    if(TCM_VERBOSE)
        message(STATUS "")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print an ERROR message. If FATAL is passed then a FATAL_ERROR is emitted.
#
function(tcm_error arg_TEXT)
    set(options FATAL)
    cmake_parse_arguments(PARSE_ARGV 1 "arg" "${options}" "" "")
    if(arg_FATAL)
        message(FATAL_ERROR " [X] ${arg_TEXT}")
    elseif (TCM_VERBOSE)
        message(STATUS "[!] ${arg_TEXT}")
    endif ()
endfunction()

#-------------------------------------------------------------------------------
#   Print a WARN message.
#
function(tcm_warn arg_TEXT)
    set(options AUTHOR_WARNING)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "" "")
    if(arg_AUTHOR_WARNING)
        message(AUTHOR_WARNING "/!\\ ${arg_TEXT}")
    elseif(TCM_VERBOSE)
        message(STATUS "/!\\ ${arg_TEXT}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print an INFO message.
#
function(tcm_info arg_TEXT)
    if(TCM_VERBOSE)
        message(STATUS "(!) ${arg_TEXT}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print an STATUS message.
#
function(tcm_log arg_TEXT)
    if(TCM_VERBOSE)
        message(STATUS "${arg_TEXT}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print a DEBUG message.
#
function(tcm_debug arg_TEXT)
    if(TCM_VERBOSE)
        message(DEBUG "${arg_TEXT}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print a TRACE message.
#
function(tcm_trace arg_TEXT)
    if(TCM_VERBOSE)
        message(TRACE "${arg_TEXT}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Begin a check section.
#
macro(tcm_check_start arg_TEXT)
    if(TCM_VERBOSE)
        message(CHECK_START "${arg_TEXT}")
    endif()
    tcm_indent()
endmacro()

#-------------------------------------------------------------------------------
#   Pass a check section.
#
macro(tcm_check_pass arg_TEXT)
    tcm_outdent()
    if(TCM_VERBOSE)
        message(CHECK_PASS "(v) ${arg_TEXT}")
    endif()
endmacro()

#-------------------------------------------------------------------------------
#   Fail a check section.
#
macro(tcm_check_fail arg_TEXT)
    tcm_outdent()
    if(TCM_VERBOSE)
        message(CHECK_FAIL "(x) ${arg_TEXT}")
    endif()
endmacro()

#-------------------------------------------------------------------------------
#   Begin a section.
#
macro(tcm_section arg_NAME)
    list(APPEND CMAKE_MESSAGE_CONTEXT ${arg_NAME})
endmacro()

#-------------------------------------------------------------------------------
#   End a section.
#
macro(tcm_section_end)
    list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endmacro()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Setup logging module.
#
macro(tcm__setup_logging)
    if(NOT DEFINED CMAKE_MESSAGE_CONTEXT_SHOW)
        set(CMAKE_MESSAGE_CONTEXT_SHOW TRUE)
    endif ()

    if(NOT DEFINED CMAKE_MESSAGE_CONTEXT)
        set(CMAKE_MESSAGE_CONTEXT ${PROJECT_NAME})
    endif ()

    if(NOT PROJECT_IS_TOP_LEVEL AND NOT ${PROJECT_NAME} IN_LIST CMAKE_MESSAGE_CONTEXT)
        tcm_section(${PROJECT_NAME})
    endif ()
endmacro()
