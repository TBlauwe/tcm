# ------------------------------------------------------------------------------
# File:
#   CMakeLists.txt
#
# Author:
#   TBlauwe
#
# Description:
#   Opinionated CMake module to share and manage common functionality and settings for C++ / C project.
#   Functions and macros are all prefixed with tcm_.
#   Private functions and macros are all prefixed with tcm__ (double underscore).
#
# Usage:
#   include(cmake/tcm.cmake) # tcm_setup() is called automatically.
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.21) # TODO Check for minimum required version.


# ------------------------------------------------------------------------------
# --- System Modules
# ------------------------------------------------------------------------------
include(CMakePrintHelpers)
include(CMakeDependentOption)
#include(CMakeParseArguments) # Since 3.5, it is implemented natively. https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html


# ------------------------------------------------------------------------------
# --- OPTIONS
# ------------------------------------------------------------------------------
option(TCM_VERBOSE "Verbose messages during CMake runs" ${PROJECT_IS_TOP_LEVEL})


# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------


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
    if(TCM_VERBOSE)
        message(STATUS "/!\\ ${_text}")
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
        message(STATUS "    ${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print a DEBUG message.
#
function(tcm_debug _text)
    if(TCM_VERBOSE)
        message(DEBUG "    ${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Print a TRACE message.
#
function(tcm_trace _text)
    if(TCM_VERBOSE)
        message(TRACE "    ${_text}")
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Begin a check section.
#
macro(tcm_check_start _text)
    if(TCM_VERBOSE)
        message(CHECK_START "    ${_text}")
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
    list(POP_BACK TCM_SECTION_LIST)
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   Begin a section.
#
macro(tcm_begin_section _name)
    list(APPEND TCM_SECTION_LIST ${_name})
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   End a section.
#
macro(tcm_end_section)
    list(POP_BACK TCM_SECTION_LIST)
    tcm__refresh_message_context()
endmacro()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Refresh CMAKE_MESSAGE_CONTEXT a section.
#
function(tcm__refresh_message_context)
    string(REPLACE ";" " | " _TCM_SECTIONS_STRING "${TCM_SECTION_LIST}")
    set(CMAKE_MESSAGE_CONTEXT ${_TCM_SECTIONS_STRING} PARENT_SCOPE)
endfunction()


# ------------------------------------------------------------------------------
# --- CPM
# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.

if(NOT DEFINED CPM_DOWNLOAD_VERSION)
    set(CPM_DOWNLOAD_VERSION 0.40.2)
    set(CPM_HASH_SUM "c8cdc32c03816538ce22781ed72964dc864b2a34a310d3b7104812a5ca2d835d")
endif()

if(CPM_SOURCE_CACHE)
    set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
elseif(DEFINED ENV{CPM_SOURCE_CACHE})
    set(CPM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
else()
    set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
endif()

# Expand relative path. This is important if the provided path contains a tilde (~)
get_filename_component(CPM_DOWNLOAD_LOCATION ${CPM_DOWNLOAD_LOCATION} ABSOLUTE)

function(download_cpm)
    tcm_info("Downloading CPM.cmake to ${CPM_DOWNLOAD_LOCATION}")
    file(DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
            ${CPM_DOWNLOAD_LOCATION}
            EXPECTED_HASH SHA256=${CPM_HASH_SUM}
    )
endfunction()

if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    download_cpm()
else()
    # resume download if it previously failed
    file(READ ${CPM_DOWNLOAD_LOCATION} check)
    if("${check}" STREQUAL "")
        download_cpm()
    endif()
endif()

include(${CPM_DOWNLOAD_LOCATION})

# ------------------------------------------------------------------------------
# --- CODE-BLOCKS
# ------------------------------------------------------------------------------
# Description:
#   Generate markdown code blocks from a source.
#   Included source file path must be relative to project source directory.
#   File's extension is used to determine the code block language.
#   If included files have not changed, then files will be left untouched.
#
# Usage :
#   // In some file, like README.md
#   <!--BEGIN_INCLUDE="relative_path/to/file.cpp"-->
#   Everything between this two tags will be replaced by the content of the file inside a code block.
#   <!--END_INCLUDE-->
#
#   // In some cmake file, like root CMakeLists.txt
#   tcm_code_block(README.md)

function(tcm_code_block _file)
    message(CHECK_START "Looking for code-blocks to update in ${_file}")

    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_file})
        message(CHECK_FAIL "Skipping : file does not exist.")
        return()
    endif ()

    set(NEED_UPDATE FALSE)	# Update file when at least one code block was updated.
    set(STAMP_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/code-blocks")
    set(PATTERN "(<!--BEGIN_INCLUDE=\"(.*)\"-->)(.*)(<!--END_INCLUDE-->)")
    file(READ ${FILENAME} INPUT_CONTENT)
    string(REGEX MATCHALL ${PATTERN} matches ${INPUT_CONTENT})

    if(NOT matches)
        message(CHECK_FAIL "Skipping : no code-block found.")
        return()
    endif ()

    file(MAKE_DIRECTORY ${STAMP_OUTPUT_DIRECTORY})
    foreach(match ${matches})

        string(REGEX REPLACE ${PATTERN} "\\1;\\2;\\3;\\4" groups ${match})
        list(GET groups 0 HEADER)
        list(GET groups 1 FILE_PATH)
        list(GET groups 2 BODY)
        list(GET groups 3 FOOTER)

        # First, check if file needs updating.
        set(ABSOLUTE_INC_FILE_PATH "${PROJECT_SOURCE_DIR}/${FILE_PATH}")
        set(ABSOLUTE_STAMP_FILE_PATH "${STAMP_OUTPUT_DIRECTORY}/${FILE_PATH}.stamp")
        file(TIMESTAMP ${ABSOLUTE_INC_FILE_PATH} src_timestamp)
        file(TIMESTAMP ${ABSOLUTE_STAMP_FILE_PATH} dest_timestamp)

        if(${ABSOLUTE_INC_FILE_PATH} IS_NEWER_THAN ${ABSOLUTE_STAMP_FILE_PATH})
            set(NEED_UPDATE TRUE)
            get_filename_component(_DIR ${FILE_PATH} DIRECTORY)
            file(MAKE_DIRECTORY ${STAMP_OUTPUT_DIRECTORY}/${_DIR})
            file(TOUCH ${ABSOLUTE_STAMP_FILE_PATH})

            # Build new code block
            file(READ ${ABSOLUTE_INC_FILE_PATH} NEW_BODY)
            get_filename_component(FILEPATH_EXT ${FILE_PATH} EXT)
            string(REPLACE "." "" FILEPATH_EXT ${FILEPATH_EXT})
            string(REPLACE "${HEADER}${BODY}${FOOTER}" "${HEADER}\n```${FILEPATH_EXT}\n${NEW_BODY}\n```\n${FOOTER}" INPUT_CONTENT ${INPUT_CONTENT})
        endif ()
    endforeach()

    if(NEED_UPDATE) # At least one code block was updated.
        file(WRITE ${_file} ${INPUT_CONTENT})
        message(CHECK_PASS "done.")
    else()
        message(CHECK_PASS "done. No code-blocks needed to be updated.")
    endif()
endfunction()

# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# --- SETUP
# ------------------------------------------------------------------------------
macro(tcm_setup)
    set(CMAKE_MESSAGE_CONTEXT_SHOW  TRUE)
    set(TCM_SECTION_LIST "${PROJECT_NAME}")
    tcm__refresh_message_context()
endmacro()

# Automatically setup tcm on include
tcm_setup()
