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
#   TCM version of `message()`, a wrapper of CMake `message()`, used the same way.
#   These messages can be turned with `TCM_VERBOSE OFF`.
#   Short-hand functions are also available below.
#   Credits : https://stackoverflow.com/questions/18968979/how-to-make-colorized-message-with-cmake
function(tcm_message)
    if(CMAKE_COLOR_DIAGNOSTICS)
        string(ASCII 27 Esc)
        set(reset        "${Esc}[m")
        set(bold         "${Esc}[1m")
        set(red          "${Esc}[31m")
        set(green        "${Esc}[32m")
        set(yellow       "${Esc}[33m")
        set(blue         "${Esc}[34m")
        set(magenta      "${Esc}[35m")
        set(cyan         "${Esc}[36m")
        set(white        "${Esc}[37m")
        set(bold_red     "${Esc}[1;31m")
        set(bold_green   "${Esc}[1;32m")
        set(bold_yellow  "${Esc}[1;33m")
        set(bold_blue    "${Esc}[1;34m")
        set(bold_magenta "${Esc}[1;35m")
        set(bold_cyan    "${Esc}[1;36m")
        set(bold_white   "${Esc}[1;37m")
    endif ()

    list(GET ARGV 0 type)
    if(type STREQUAL FATAL_ERROR OR type STREQUAL SEND_ERROR)
        list(REMOVE_AT ARGV 0)
        message(${type} "${bold_red}[X]${reset} ${ARGV}")
    elseif(type STREQUAL ERROR)
        list(REMOVE_AT ARGV 0)
        message(STATUS "${bold_red}[!]${reset} ${ARGV}")
    elseif(type STREQUAL WARNING)
        list(REMOVE_AT ARGV 0)
        message(STATUS "${bold_yellow}/!\\${reset} ${ARGV}")
    elseif(type STREQUAL AUTHOR_WARNING)
        list(REMOVE_AT ARGV 0)
        message(${type} "${bold_cyan}/!\\${reset} ${ARGV}")
    elseif(NOT TCM_VERBOSE)
        return()
    elseif(type STREQUAL INFO)
        list(REMOVE_AT ARGV 0)
        message(STATUS "${bold_blue}(!)${reset} ${ARGV}")
    elseif(type STREQUAL CHECK_PASS)
        list(REMOVE_AT ARGV 0)
        message(${type} "${bold_green}${ARGV}${reset}")
    elseif(type STREQUAL CHECK_FAIL)
        list(REMOVE_AT ARGV 0)
        message(${type} "${bold_red}${ARGV}${reset}")
    elseif(
            type STREQUAL STATUS
         OR type STREQUAL DEBUG
         OR type STREQUAL TRACE
         OR type STREQUAL CHECK_START
    )
        list(REMOVE_AT ARGV 0)
        message(${type} "${ARGV}")
    else()
        message("${ARGV}")
    endif()

endfunction()

#-------------------------------------------------------------------------------
#   Print a FATAL ERROR message.
#
function(tcm_fatal_error)
    tcm_message(FATAL_ERROR ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print an ERROR message but does not abort. Use tcm_fatal_error.
#
function(tcm_error)
    tcm_message(ERROR ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print a WARN message. For authors, use `tcm_author_warn()`.
#
function(tcm_warn)
    tcm_message(WARNING ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print a AUTHOR_WARNING message. For users, use `tcm_warn()`.
#
function(tcm_author_warn)
    tcm_message(AUTHOR_WARNING ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print an INFO message.
#
function(tcm_info)
    tcm_message(INFO ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print an STATUS message.
#
function(tcm_log)
    tcm_message(STATUS ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print a DEBUG message.
#
function(tcm_debug)
    tcm_message(DEBUG ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Print a TRACE message.
#
function(tcm_trace arg_TEXT)
    tcm_message(TRACE ${ARGV})
endfunction()

#-------------------------------------------------------------------------------
#   Begin a check section.
#
macro(tcm_check_start)
    tcm_message(CHECK_START ${ARGV})
    tcm_indent()
endmacro()

#-------------------------------------------------------------------------------
#   Pass a check section.
#
macro(tcm_check_pass)
    tcm_outdent()
    tcm_message(CHECK_PASS ${ARGV})
endmacro()

#-------------------------------------------------------------------------------
#   Fail a check section.
#
macro(tcm_check_fail)
    tcm_outdent()
    tcm_message(CHECK_FAIL ${ARGV})
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
