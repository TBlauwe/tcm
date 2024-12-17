# ------------------------------------------------------------------------------
# --- LOGGING
# ------------------------------------------------------------------------------
# This section contains some utility functions for logging purposes
# They are simple wrappers over `message()`, whom are mostly noop when current project is not top level.

#-------------------------------------------------------------------------------
#   Indent cmake message.
#
macro(tcm_indent)
    list(APPEND CMAKE_MESSAGE_INDENT "    ${ARGN}")
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
function(tcm_error _text)
    set(options FATAL)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(arg_FATAL)
        message(FATAL_ERROR " [X] ${_text}")
    elseif (TCM_VERBOSE)
        message(STATUS "[!] ${_text}")
    endif ()
endfunction()

#-------------------------------------------------------------------------------
#   Print a WARN message.
#
function(tcm_warn _text)
    set(options AUTHOR_WARNING)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(arg_AUTHOR_WARNING)
        message(AUTHOR_WARNING "/!\\ ${_text}")
    elseif(TCM_VERBOSE)
        message("/!\\ ${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print an INFO message.
#
function(tcm_info _text)
    if(TCM_VERBOSE)
        message(STATUS "(!) ${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print an STATUS message.
#
function(tcm_log _text)
    if(TCM_VERBOSE)
        message(STATUS "${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print a DEBUG message.
#
function(tcm_debug _text)
    if(TCM_VERBOSE)
        message(DEBUG "${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print a TRACE message.
#
function(tcm_trace _text)
    if(TCM_VERBOSE)
        message(TRACE "${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Begin a check section.
#
macro(tcm_check_start _text)
    if(TCM_VERBOSE)
        message(CHECK_START "${_text}")
    endif()
    tcm_indent()
endmacro()

#-------------------------------------------------------------------------------
#   Pass a check section.
#
macro(tcm_check_pass _text)
    tcm_outdent()
    if(TCM_VERBOSE)
        message(CHECK_PASS "(v) ${_text}")
    endif()
endmacro()

#-------------------------------------------------------------------------------
#   Fail a check section.
#
macro(tcm_check_fail _text)
    tcm_outdent()
    if(TCM_VERBOSE)
        message(CHECK_FAIL "(x) ${_text}")
    endif()
endmacro()

#-------------------------------------------------------------------------------
#   End a section.
#
macro(tcm_end_section)
    list(POP_BACK TCM__SECTION_LIST)
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   Begin a section.
#
macro(tcm_begin_section _name)
    list(APPEND TCM__SECTION_LIST ${_name})
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   End a section.
#
macro(tcm_end_section)
    list(POP_BACK TCM__SECTION_LIST)
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Setup logging by setting some variables.
#
macro(tcm__setup_logging)
    set(CMAKE_MESSAGE_CONTEXT_SHOW  TRUE)
    set(TCM__SECTION_LIST "${PROJECT_NAME}")
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Refresh CMAKE_MESSAGE_CONTEXT a section.
#
function(tcm__refresh_message_context)
    string(REPLACE ";" " | " _TCM_SECTIONS_STRING "${TCM__SECTION_LIST}")
    set(CMAKE_MESSAGE_CONTEXT ${_TCM_SECTIONS_STRING} PARENT_SCOPE)
endfunction()
