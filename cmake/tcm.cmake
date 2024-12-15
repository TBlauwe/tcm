# ------------------------------------------------------------------------------
# File:
#   tcm.cmake
#
# Author:
#   TBlauwe
#
# Description:
#   Opinionated CMake module to share and manage common functionality and settings for C++ / C project.
#   Functions and macros are all prefixed with tcm_.
#   Private functions and macros are all prefixed with tcm__ (double underscore).
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.25) # Required for `SOURCE_FROM_CONTENT` : https://cmake.org/cmake/help/latest/command/try_compile.html


# ------------------------------------------------------------------------------
# --- System Modules
# ------------------------------------------------------------------------------
#include(CMakePrintHelpers)
#include(CMakeDependentOption)
#include(CMakeParseArguments) # Since 3.5, it is implemented natively. https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html



# ------------------------------------------------------------------------------
# --- OPTIONS
# ------------------------------------------------------------------------------
option(TCM_VERBOSE "Verbose messages during CMake runs" ${PROJECT_IS_TOP_LEVEL})
option(TCM_EXE_DIR "A convenient folder to store executables" "${CMAKE_CURRENT_BINARY_DIR}/bin")


# ------------------------------------------------------------------------------
# --- OPTIONS
# ------------------------------------------------------------------------------
macro(tcm__default_value _arg _value)
    if(NOT DEFINED ${_arg})
        set(${_arg} ${_value})
    endif ()
endmacro()


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
#   Refresh CMAKE_MESSAGE_CONTEXT a section.
#
function(tcm__refresh_message_context)
    string(REPLACE ";" " | " _TCM_SECTIONS_STRING "${TCM__SECTION_LIST}")
    set(CMAKE_MESSAGE_CONTEXT ${_TCM_SECTIONS_STRING} PARENT_SCOPE)
endfunction()

# ------------------------------------------------------------------------------
# --- Miscellaneous functions
# ------------------------------------------------------------------------------
# Prevent warnings from displaying when building target
# Useful when you do not want libraries warnings polluting your build output
# TODO Seems to work in some cases but not all.
function(tcm_suppress_warnings _target)
    set_target_properties(${_target} PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${_target},INTERFACE_INCLUDE_DIRECTORIES>)
endfunction()

# Define "-D${_option}" for _target when _option is ON.
function(tcm_option_define _target _option)
    if (${_option})
        target_compile_definitions(${_target} PUBLIC "${_option}")
    endif ()
endfunction()

# TODO Also look at embedding ?
# Copy folder _src_dir to _dst_dir before target is built.
function(tcm_target_assets _target _src_dir _dst_dir)
    add_custom_target(${_target}_copy_assets
            COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${_src_dir} ${_dst_dir}
            COMMENT "(${_target}) - Copying assets from directory ${_src_dir} to ${_dst_dir}"
    )
    add_dependencies(${_target} ${_target}_copy_assets)
endfunction()

# Disallow in-source builds
# Not recommended, you should still do it, as it should be called as early as possible, before installing tcm.
# From : https://github.com/friendlyanon/cmake-init/
function(tcm_prevent_in_source_build)
    if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
        tcm_error("In-source builds are not allowed. Please create a separate build directory and run cmake from there" FATAL)
    endif()
endfunction()

function(tcm_target_enable_optimisation _target)
    if(TCM_EMSCRIPTEN)
        target_compile_options(${_target} PUBLIC "-Os")
        target_link_options(${_target} PUBLIC "-Os")

    elseif (TCM_CLANG OR TCM_APPLE_CLANG OR TCM_GCC)
        target_compile_options(${_target} PRIVATE
                $<$<CONFIG:RELEASE>:-O3>
                $<$<CONFIG:RELEASE>:-flto>
                $<$<CONFIG:RELEASE>:-march=native>
        )
        target_link_options(${_target} PRIVATE $<$<CONFIG:RELEASE>:-O3>)

    elseif (TCM_MSVC)
        target_compile_options(${_target} PRIVATE $<$<CONFIG:RELEASE>:/O3>)
        target_link_options(${_target} PRIVATE $<$<CONFIG:RELEASE>:/O3>)

    else ()
        tcm_warn("tcm_target_enable_optimisation(${_target}) does not support : ${CMAKE_CXX_COMPILER_ID}."
                "Following compiler are supported: Clang, GNU, MSVC, AppleClang and emscripten.")
    endif ()
endfunction()

function(tcm_target_enable_warnings _target)
    if (TCM_CLANG OR TCM_APPLE_CLANG OR TCM_GCC OR TCM_EMSCRIPTEN)
        target_compile_options(${_target} PRIVATE
                #$<$<CONFIG:RELEASE>:-Werror> # Treat warnings as error
                $<$<CONFIG:Debug>:-Wshadow>
                $<$<CONFIG:Debug>:-Wunused>
                -Wall -Wextra
                -Wnon-virtual-dtor
                -Wold-style-cast
                -Wcast-align
                -Woverloaded-virtual
                -Wpedantic
                -Wconversion
                -Wsign-conversion
                -Wdouble-promotion
                -Wformat=2
                -Wno-c++98-compat
                -Wno-c++98-compat-pedantic
                -Wno-c++98-c++11-compat-pedantic
        )

    elseif (TCM_MSVC)
        target_compile_options(${_target} PRIVATE
                #$<$<CONFIG:RELEASE>:/WX> # Treat warnings as error
                /W4
                /w14242 /w14254 /w14263
                /w14265 /w14287 /we4289
                /w14296 /w14311 /w14545
                /w14546 /w14547 /w14549
                /w14555 /w14619 /w14640
                /w14826 /w14905 /w14906
                /w14928)

    else ()
        tcm_warn("tcm_target_enable_warnings(${_target}) does not support : ${CMAKE_CXX_COMPILER_ID}."
                "Following compiler are supported: Clang, GNU, MSVC, AppleClang and emscripten.")
    endif ()
endfunction()

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
#   tcm_code_blocks(README.md)

function(tcm_code_blocks _file)
    message(CHECK_START "Looking for code-blocks to update in ${_file}")

    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_file})
        message(CHECK_FAIL "Skipping : file does not exist.")
        return()
    endif ()

    set(NEED_UPDATE FALSE)	# Update file when at least one code block was updated.
    set(STAMP_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/code-blocks")
    set(PATTERN "(<!--BEGIN_INCLUDE=\"(.*)\"-->)(.*)(<!--END_INCLUDE-->)")
    file(READ ${_file} INPUT_CONTENT)
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
# --- CPM
# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.

macro(tcm_setup_cpm)
    set(CPM_INDENT "   ")
    set(CPM_USE_NAMED_CACHE_DIRECTORIES ON)  # See https://github.com/cpm-cmake/CPM.cmake?tab=readme-ov-file#cpm_use_named_cache_directories
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
    tcm_log("Using CPM : ${CPM_DOWNLOAD_LOCATION}")
endmacro()

# ------------------------------------------------------------------------------
# --- SETUP PROJECT VERSION
# ------------------------------------------------------------------------------
# Description:
#   Set project's version using semantic versioning, either from git in dev mode or from version file.
#   Expected to be called from root CMakeLists.txt and from a valid git directory.

# Credits:
#   Adapted from https://github.com/nunofachada/cmake-git-semver/blob/master/GetVersionFromGitTag.cmake
#
# Usage :
#   tcm_setup_project_version()
function(tcm_setup_project_version)

    if (GIT_FOUND AND ${PROJECT_IS_TOP_LEVEL})
        # Get last tag from git
        execute_process(COMMAND ${GIT_EXECUTABLE} describe --abbrev=0 --tags
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE VERSION_STRING
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
        )

        string(REGEX MATCH "v?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?" VERSION_STRING ${VERSION_STRING})
        if(NOT VERSION_STRING)
            set(${PROJECT_NAME}_VERSION_MAJOR "0")
            set(${PROJECT_NAME}_VERSION_MINOR "0")
            set(${PROJECT_NAME}_VERSION_PATCH "0")
        else()
            string(REPLACE "." ";" PARTIAL_VERSION_LIST ${VERSION_STRING})
            list(LENGTH PARTIAL_VERSION_LIST LIST_LENGTH)

            # Set Major
            list(GET PARTIAL_VERSION_LIST 0 VALUE)
            set(${PROJECT_NAME}_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
            set(VERSION ${VALUE})

            #Set Minor
            if(LIST_LENGTH GREATER_EQUAL 2)
                list(GET PARTIAL_VERSION_LIST 1 VALUE)
                set(${PROJECT_NAME}_VERSION_MINOR ${VALUE} PARENT_SCOPE)
                string(APPEND VERSION ".${VALUE}")
            else ()
                set(${PROJECT_NAME}_VERSION_MINOR 0 PARENT_SCOPE)
                string(APPEND VERSION ".0")
            endif ()

            #Set Patch
            if(LIST_LENGTH GREATER_EQUAL 3)
                list(GET PARTIAL_VERSION_LIST 2 VALUE)
                set(${PROJECT_NAME}_VERSION_PATCH ${VALUE} PARENT_SCOPE)
                string(APPEND VERSION ".${VALUE}")
            else ()
                set(${PROJECT_NAME}_VERSION_PATCH 0 PARENT_SCOPE)
                string(APPEND VERSION ".0")
            endif ()
        endif()

        set(${PROJECT_NAME}_VERSION ${VERSION} PARENT_SCOPE)

        # Save version to file
        file(WRITE ${CMAKE_SOURCE_DIR}/VERSION ${VERSION})

    else()
        # Git not available, get version from file
        file(STRINGS "VERSION" VERSION)
        set(${PROJECT_NAME}_VERSION ${VERSION} PARENT_SCOPE)

        string(REPLACE "." ";" VERSION_LIST ${VERSION})
        list(GET VERSION_LIST 0 VALUE)
        set(${PROJECT_NAME}_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
        list(GET VERSION_LIST 1 VALUE)
        set(${PROJECT_NAME}_VERSION_MINOR ${VALUE} PARENT_SCOPE)
        list(GET VERSION_LIST 2 VALUE)
        set(${PROJECT_NAME}_VERSION_PATCH ${VALUE} PARENT_SCOPE)
    endif()

    tcm_log("Project Version : ${VERSION}")
endfunction()

# ------------------------------------------------------------------------------
# --- SETUP-CACHE
# ------------------------------------------------------------------------------
# Description:
#   Setup cache (only if top level project), like ccache (https://ccache.dev/) if available on system.

# Usage :
#   tcm_setup_cache()

function(tcm_setup_cache)
    if(EMSCRIPTEN) # Doesn't seems to work with emscripten (https://github.com/emscripten-core/emscripten/issues/11974)
        return()
    endif()

    set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
    set(CACHE_OPTION_VALUES "ccache" "sccache")
    set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})
    list(
            FIND
            CACHE_OPTION_VALUES
            ${CACHE_OPTION}
            CACHE_OPTION_INDEX
    )

    if(${CACHE_OPTION_INDEX} EQUAL -1)
        tcm_log("Using custom compiler cache system: '${CACHE_OPTION}'. Supported entries are ${CACHE_OPTION_VALUES}")
    endif()

    find_program(CACHE_BINARY NAMES ${CACHE_OPTION_VALUES})
    if(CACHE_BINARY)
        tcm_log("Using Cache System : ${CACHE_BINARY}.")
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_C_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_CUDA_COMPILER_LAUNCHER "${CACHE_BINARY}" PARENT_SCOPE)
    else()
        tcm_warn("${CACHE_OPTION} is enabled but was not found. Not using it")
    endif()
endfunction()


# ------------------------------------------------------------------------------
# --- SETUP-DOCUMENTATION
# ------------------------------------------------------------------------------
# Description:
#   Setup documentation using doxygen and doxygen-awesome.
#   See tcm_setup_docs() for overridable options.
#   TCM_DOXYGEN_INCLUDE_DIR
#   TCM_DOXYGEN_EXAMPLE_DIR
#
# Usage :
#   tcm_setup_docs()

function(tcm_setup_docs)
    set(options)
    set(oneValueArgs
            DOXYGEN_AWESOME_VERSION
            DOXYFILE
            HEADER
            FOOTER
            CSS
            LAYOUT
            OUTPUT_DIR
            HTML_DIR
            PAGES_DIR
            ASSETS_DIR
            INCLUDE_DIR
            EXAMPLES_DIR
            LOGO
    )
    cmake_parse_arguments(PARSE_ARGV 0 TCM "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm__default_value(TCM_DOXYGEN_AWESOME_VERSION "v2.3.4")
    tcm__default_value(TCM_DOXYFILE     "${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen/Doxyfile.in")
    tcm__default_value(TCM_HEADER       "${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen/header.html")
    tcm__default_value(TCM_FOOTER       "${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen/footer.html")
    tcm__default_value(TCM_CSS          "${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen/custom.css")
    tcm__default_value(TCM_LAYOUT       "${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen/DoxygenLayout.xml")
    tcm__default_value(TCM_OUTPUT_DIR   "${CMAKE_CURRENT_BINARY_DIR}/doxygen")
    tcm__default_value(TCM_HTML_DIR     "${TCM_OUTPUT_DIR}/html")
    tcm__default_value(TCM_PAGES_DIR    "${PROJECT_SOURCE_DIR}/docs/pages")
    tcm__default_value(TCM_ASSETS_DIR   "${PROJECT_SOURCE_DIR}/assets")
    tcm__default_value(TCM_LOGO         "${PROJECT_SOURCE_DIR}/assets/logo_small_dark.png")

    tcm_begin_section("DOCS")
        # Doxygen is a documentation generator and static analysis tool for software source trees.
        find_package(Doxygen QUIET)
        if(NOT Doxygen_FOUND)
            tcm_warn("Doxygen not found -> Skipping docs.")
            tcm_end_section()
            return()
        endif()

        # Doxygen awesome CSS is a custom CSS theme for doxygen html-documentation with lots of customization parameters.
        CPMAddPackage(
                NAME DOXYGEN_AWESOME_CSS
                GIT_TAG ${TCM_DOXYGEN_AWESOME_VERSION}
                GITHUB_REPOSITORY jothepro/doxygen-awesome-css
        )
        if(NOT DOXYGEN_AWESOME_CSS_ADDED)
            tcm_warn("Could not add DOXYGEN_AWESOME_CSS -> Skipping docs.")
            tcm_end_section()
            return()
        endif()

        configure_file(${TCM_DOXYFILE} ${TCM_OUTPUT_DIR}/Doxyfile)
        configure_file(${TCM_HEADER} ${TCM_OUTPUT_DIR}/header.html)
        configure_file(${TCM_FOOTER} ${TCM_OUTPUT_DIR}/footer.html)

        file(GLOB_RECURSE DOCS_PAGES "${TCM_PAGES_DIR}/*.md")
        file(GLOB_RECURSE DOCS_ASSETS "${TCM_ASSETS_DIR}/*")

        if(IS_DIRECTORY ${TCM_ASSETS_DIR})
            set(COPY_ASSETS_DIR 1)
        else()
            set(COPY_ASSETS_DIR 0)
        endif()

        add_custom_target(
                docs
                COMMAND ${CMAKE_COMMAND} -E make_directory "${TCM_OUTPUT_DIR}"
                COMMAND ${CMAKE_COMMAND} -E make_directory "${TCM_HTML_DIR}"
                COMMAND ${CMAKE_COMMAND} -E $<IF:${COPY_ASSETS_DIR},"copy directory ${TCM_ASSETS_DIR} ${TCM_HTML_DIR}","true">
                COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
                COMMAND echo "   Docs written to: ${TCM_HTML_DIR}"
                WORKING_DIRECTORY "${TCM_OUTPUT_DIR}"
                SOURCES
                ${TCM_DOXYFILE}
                ${TCM_HEADER}
                ${TCM_FOOTER}
                ${TCM_CSS}
                ${TCM_LAYOUT}
                ${DOCS_PAGES}
                ${DOCS_ASSETS}
        )

        # Utility target to open docs
        add_custom_target(
                open_docs
                COMMAND "${TCM_HTML_DIR}/index.html"
        )
        add_dependencies(open_docs docs)
    tcm_end_section()

endfunction()


# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------
macro(tcm__setup_variables)
    #-------------------------------------------------------------------------------
    # Set host machine
    set (TCM_HOST_WINDOWS 0)
    set (TCM_HOST_OSX 0)
    set (TCM_HOST_LINUX 0)
    if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
        set(TCM_HOST_WINDOWS 1)
        tcm_debug("Host system : Windows")
    elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
        set(TCM_HOST_OSX 1)
        tcm_debug("Host system : OSX")
    elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
        set(TCM_HOST_LINUX 1)
        tcm_debug("Host system : Linux")
    else()
        set(TCM_HOST_LINUX 1)
        tcm_debug("Host system not recognized, setting to 'Linux'")
    endif()

    #-------------------------------------------------------------------------------
    # Set Compiler
    tcm_debug("Compiler : ${CMAKE_CXX_COMPILER_ID}")
    if (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
        set(TCM_CLANG 1)
        if (${CMAKE_CXX_COMPILER_ID} MATCHES "AppleClang")
            set(TCM_APPLE_CLANG 1)
        endif()
        if (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC") # using clang with clang-cl front end
            set(TCM_CLANG_CL 1)
        endif()
    elseif (${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
        set(TCM_GCC 1)
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
        set(TCM_INTEL 1)
    elseif (MSVC)
        set(TCM_MSVC 1)
    else()
        if (EMSCRIPTEN)
            set(TCM_EMSCRIPTEN 1)
            set(TCM_CLANG 1)
        #elseif (TCM_ANDROID)
        #    set(TCM_CLANG 1)
        endif()
    endif()

    #-------------------------------------------------------------------------------
    #   Computed Gotos
    try_compile(TCM_SUPPORT_COMPUTED_GOTOS SOURCE_FROM_CONTENT computed_goto_test.c "int main() { static void* labels[] = {&&label1, &&label2}; int i = 0; goto *labels[i]; label1: return 0; label2: return 1; } ")
    tcm_debug("Feature support - computed gotos : ${TCM_SUPPORT_COMPUTED_GOTOS}")

    #-------------------------------------------------------------------------------
    #   Warning Guard
    #
    # target_include_directories with the SYSTEM modifier will request the compiler
    # to omit warnings from the provided paths, if the compiler supports that.
    # This is to provide a user experience similar to find_package when
    # add_subdirectory or FetchContent is used to consume this project
    if(PROJECT_IS_TOP_LEVEL)
        set(TCM_WARNING_GUARD "")
    else()
        option(TCM_INCLUDES_WITH_SYSTEM "Use SYSTEM modifier for shared's includes, disabling warnings" ON)
        mark_as_advanced(TCM_INCLUDES_WITH_SYSTEM)
        if(TCM_INCLUDES_WITH_SYSTEM)
            set(TCM_WARNING_GUARD SYSTEM)
        endif()
    endif ()

endmacro()

# ------------------------------------------------------------------------------
# --- SETUP
# ------------------------------------------------------------------------------
macro(tcm_setup)
    set(CMAKE_MESSAGE_CONTEXT_SHOW  TRUE)
    set(TCM__SECTION_LIST "${PROJECT_NAME}")
    tcm__refresh_message_context()
    tcm__setup_variables()
endmacro()

# Automatically setup tcm on include
tcm_setup()
