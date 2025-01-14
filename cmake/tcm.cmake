# ------------------------------------------------------------------------------
#        File: tcm.cmake
#      Author: TBlauwe
# Description: A CMake module to reduce boilerplate
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.26)

get_property(TCM_INITIALIZED GLOBAL PROPERTY TCM_INITIALIZED SET)

#If tcm is already initialized, just update logging module to set message context
if(TCM_INITIALIZED)
    tcm__module_logging()
    return()
endif ()


# ------------------------------------------------------------------------------
# --- OPTIONS
# ------------------------------------------------------------------------------
option(TCM_VERBOSE "Verbose messages during CMake runs"         ${PROJECT_IS_TOP_LEVEL})


# ------------------------------------------------------------------------------
# --- MODULE: Arguments
#
#   This module defines functions to improve UX by checking appropriate API usage.
# ------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#   FOR INTERNAL USAGE : It should only be used by `tcm_function_parse_args(...)`.
#
#   Print argument correct usage.
#   set(api_misuse TRUE) if one misuse is detected.
#
function(tcm__check_var arg_PREFIX arg_ARGUMENT arg_REQUIRED_LIST arg_SUFFIX)
    string(APPEND usage_message "\n\t")
    if("${arg_ARGUMENT}" IN_LIST arg_REQUIRED_LIST)
        string(APPEND usage_message "${argument} ${arg_SUFFIX}")
        if("${arg_ARGUMENT}" IN_LIST ${arg_PREFIX}_KEYWORDS_MISSING_VALUES)
            set(TCM_API_MISUSE TRUE PARENT_SCOPE)
            string(APPEND usage_message " <-- Missing value(s)")
        elseif(NOT DEFINED ${arg_PREFIX}_${arg_ARGUMENT})
            set(TCM_API_MISUSE TRUE PARENT_SCOPE)
            string(APPEND usage_message " <-- Missing required argument")
        endif()
    else()
        string(APPEND usage_message "[${argument} ${arg_SUFFIX}" "]")
        if("${arg_ARGUMENT}" IN_LIST ${arg_PREFIX}_KEYWORDS_MISSING_VALUES)
            set(TCM_API_MISUSE TRUE PARENT_SCOPE)
            string(APPEND usage_message " <-- Missing value(s)")
        endif()
    endif ()
    set(usage_message ${usage_message} PARENT_SCOPE)
endfunction()


#-------------------------------------------------------------------------------
#   Ensure proper usage of function API.
#   If not, then it stop cmake execution and print correct usage.
#
function(tcm_check_proper_usage arg_FUNCTION_NAME arg_PREFIX arg_OPTIONS arg_ONE_VALUE_ARGS arg_MULTI_VALUE_ARGS arg_REQUIRED_ARGS)
    if(DEFINED ${arg_PREFIX}_TARGET AND NOT TARGET ${${arg_PREFIX}_TARGET})
        string(APPEND usage_message "\n\t${${arg_PREFIX}_TARGET} <-- Not a target.")
        set(TCM_API_MISUSE TRUE)
    endif()

    foreach (argument IN LISTS arg_OPTIONS)
        tcm__check_var(${arg_PREFIX} ${argument} "${arg_REQUIRED_ARGS}" "")
    endforeach ()
    foreach (argument IN LISTS one_value_args)
        tcm__check_var(${arg_PREFIX} ${argument} "${arg_REQUIRED_ARGS}" "<item>")
    endforeach ()
    foreach (argument IN LISTS multi_value_args)
        tcm__check_var(${arg_PREFIX} ${argument} "${arg_REQUIRED_ARGS}" "<item> ...")
    endforeach ()

    if(DEFINED TCM_API_MISUSE)
        message(FATAL_ERROR "Improper API usage: "
                "${arg_FUNCTION_NAME}("
                ${usage_message}
                "\n)"
        )
    endif ()
endfunction()


#-------------------------------------------------------------------------------
#   Set VAR to VALUE if not already defined.
#
macro(tcm_default_value arg_VAR arg_VALUE)
    if(NOT DEFINED ${arg_VAR})
        set(${arg_VAR} ${arg_VALUE})
    endif ()
endmacro()


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
macro(tcm__module_logging)
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


# ------------------------------------------------------------------------------
# --- MODULE: Assertions
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#
macro(tcm_test_section)
    if(${ARGV})
        set(TCM_TEST_SECTION_NAME ${ARGV})
    else ()
        set(TCM_TEST_SECTION_NAME ${CMAKE_CURRENT_LIST_FILE})
    endif ()
endmacro()

# ------------------------------------------------------------------------------
#
macro(tcm_test_section_end)
endmacro()


# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#   Prevent warnings from displaying when building target
#   Useful when you do not want libraries warnings polluting your build output
#   TODO Seems to work in some cases but not all.
#   TODO Isn't it dangerous ? Should we not append rather than setting ?
#
function(tcm_target_suppress_warnings arg_TARGET)
    set_target_properties(${arg_TARGET} PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${arg_TARGET},INTERFACE_INCLUDE_DIRECTORIES>)
endfunction()


#-------------------------------------------------------------------------------
#   Define "-D${OPTION}" for TARGET for each option that is ON.
#
function(tcm_target_options arg_TARGET)
    set(multi_value_args
            OPTIONS
    )
    set(required_args
            OPTIONS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "" "${multi_value_args}" "${required_args}")

    foreach (item IN LISTS arg_OPTIONS)
        if (${item})
            target_compile_definitions(${arg_TARGET} PUBLIC "${item}")
        endif ()
    endforeach ()
endfunction()


#-------------------------------------------------------------------------------
#   Set target runtime output directory
#
function(tcm_target_runtime_output_directory arg_TARGET arg_DIRECTORY)
    set_target_properties(${arg_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${arg_DIRECTORY}")
endfunction()


#-------------------------------------------------------------------------------
#   Copy .dll (and .pdb on windows) FROM <target> to TARGET folder.
#
function(tcm_target_copy_dll arg_TARGET)
    set(one_value_args FROM)
    set(required_args FROM)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "" "${required_args}")
    add_custom_command(
            TARGET ${arg_TARGET}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy -t "$<TARGET_FILE_DIR:${arg_TARGET}>" "$<TARGET_FILE:${arg_FROM}>"
            COMMAND_EXPAND_LISTS
            VERBATIM
    )
    if(TCM_WINDOWS)
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy -t "$<TARGET_FILE_DIR:${arg_TARGET}>" "$<TARGET_PDB_FILE:${arg_FROM}>"
                COMMAND_EXPAND_LISTS
                VERBATIM
        )
    endif ()
endfunction()


#-------------------------------------------------------------------------------
#   Copy all dlls required by target to its output directory.
#
function(tcm_target_copy_required_dlls arg_TARGET)
    add_custom_command(
            TARGET ${arg_TARGET}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy -t $<TARGET_FILE_DIR:${arg_TARGET}> $<TARGET_RUNTIME_DLLS:${arg_TARGET}>
            COMMAND_EXPAND_LISTS
            VERBATIM
    )
endfunction()


#-------------------------------------------------------------------------------
#   Post-build, copy files and folders to an asset/ folder inside target's output directory.
#
function(tcm_target_copy_assets arg_TARGET)
    set(one_value_args
            OUTPUT_DIR
    )
    set(multi_value_args
            FILES
    )
    set(required_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "${multi_value_args}" "${required_args}")

    foreach (item IN LISTS arg_FILES)
        file(REAL_PATH ${item} path)
        if(IS_DIRECTORY ${path})
            list(APPEND folders ${path})
        else ()
            list(APPEND files ${path})
        endif ()
    endforeach ()

    if(files)
        add_custom_command( # copy_if_different requires destination folder to exists.
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:${arg_TARGET}>/$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},assets>"
                COMMENT "Making directory $<TARGET_FILE_DIR:${arg_TARGET}>/$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},assets>"
                VERBATIM
        )
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${files} "$<TARGET_FILE_DIR:${arg_TARGET}>/$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},assets>"
                COMMENT "Copying files [${files}] to $<TARGET_FILE_DIR:${arg_TARGET}>/$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},assets>"
                VERBATIM
        )
    endif ()

    if(folders)
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different ${folders} "$<TARGET_FILE_DIR:${arg_TARGET}>/$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},assets>"
                COMMENT "Copying directories [${folders}] to $<TARGET_FILE_DIR:${arg_TARGET}>/$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},assets>"
                VERBATIM
        )
    endif ()
endfunction()


#-------------------------------------------------------------------------------
#   Disallow in-source builds
#   Not recommended. You should do it manually and early.
#   From : https://github.com/friendlyanon/cmake-init/
#
function(tcm_prevent_in_source_build)
    if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
        tcm_fatal_error("In-source builds are not allowed. Please create a separate build directory and run cmake from there")
    endif()
endfunction()


#-------------------------------------------------------------------------------
#   Enable optimisation flags on release builds for arg_TARGET
#
function(tcm_target_enable_optimisation_flags arg_TARGET)

    if(TCM_EMSCRIPTEN)
        target_compile_options(${arg_TARGET} PUBLIC "-Os")
        target_link_options(${arg_TARGET} PUBLIC "-Os")

    elseif (TCM_CLANG OR TCM_APPLE_CLANG OR TCM_GCC)
        target_compile_options(${arg_TARGET} PRIVATE
                $<$<CONFIG:RELEASE>:-O3>
                $<$<CONFIG:RELEASE>:-march=native>
        )
        target_link_options(${arg_TARGET} PRIVATE $<$<CONFIG:RELEASE>:-O3>)

    elseif (TCM_MSVC)
        target_compile_options(${arg_TARGET} PRIVATE $<$<CONFIG:RELEASE>:/O3>)
        target_link_options(${arg_TARGET} PRIVATE $<$<CONFIG:RELEASE>:/O3>)

    else ()
        tcm_warn("tcm_target_enable_optimisation(${arg_TARGET}) does not support : ${CMAKE_CXX_COMPILER_ID}."
                "Following compiler are supported: Clang, GNU, MSVC, AppleClang and emscripten.")
    endif ()
endfunction()


#-------------------------------------------------------------------------------
#   Enable warnings flags for arg_TARGET
#
function(tcm_target_enable_warning_flags arg_TARGET)

    if (TCM_CLANG OR TCM_APPLE_CLANG OR TCM_GCC OR TCM_EMSCRIPTEN)
        target_compile_options(${arg_TARGET} PRIVATE
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
        target_compile_options(${arg_TARGET} PRIVATE
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
        tcm_warn("tcm_target_enable_warnings(${arg_TARGET}) does not support : ${CMAKE_CXX_COMPILER_ID}."
                "Following compiler are supported: Clang, GNU, MSVC, AppleClang and emscripten.")
    endif ()
endfunction()


#-------------------------------------------------------------------------------
#   Prevents messages below NOTICE.
#
macro(tcm_silence_message)
    cmake_language(GET_MESSAGE_LOG_LEVEL PREVIOUS_CMAKE_MESSAGE_LOG_LEVEL)
    set(CMAKE_MESSAGE_LOG_LEVEL NOTICE)
endmacro()


#-------------------------------------------------------------------------------
#   Restore previous message log level.
#
macro(tcm_restore_message_log_level)
    if(DEFINED PREVIOUS_CMAKE_MESSAGE_LOG_LEVEL)
        set(CMAKE_MESSAGE_LOG_LEVEL ${PREVIOUS_CMAKE_MESSAGE_LOG_LEVEL})
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   Check if <FILE> has changed and outputs result to <OUTPUT_VAR>
#
function(tcm_has_changed)
    set(one_value_args
            FILE
            OUTPUT_VAR
    )
    set(required_args
            FILE
            OUTPUT_VAR
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "" "${required_args}")

    set(timestamp_file "${CMAKE_CURRENT_BINARY_DIR}/timestamps/${arg_FILE}.stamp")
    if(NOT EXISTS ${timestamp_file})
        file(TOUCH ${timestamp_file})
        set(${arg_OUTPUT_VAR} "TRUE" PARENT_SCOPE)
        return()
    else ()
        if(${arg_FILE} IS_NEWER_THAN ${timestamp_file})
            file(TOUCH ${timestamp_file})
            set(${arg_OUTPUT_VAR} "TRUE" PARENT_SCOPE)
            return()
        else ()
            set(${arg_OUTPUT_VAR} "FALSE" PARENT_SCOPE)
            return()
        endif ()
    endif ()
endfunction()


# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   For internal usage.
#   Set some useful CMake variables.
#
macro(tcm__module_variables)
    tcm_default_value(TCM_EXE_DIR "${PROJECT_BINARY_DIR}/bin")

    #-------------------------------------------------------------------------------
    # Set host machine
    #
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
    #
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
    #
    if(NOT DEFINED TCM_SUPPORT_COMPUTED_GOTOS)
        try_compile(TCM_SUPPORT_COMPUTED_GOTOS SOURCE_FROM_CONTENT computed_goto_test.c "int main() { static void* labels[] = {&&label1, &&label2}; int i = 0; goto *labels[i]; label1: return 0; label2: return 1; } ")
        set(TCM_SUPPORT_COMPUTED_GOTOS "${TCM_SUPPORT_COMPUTED_GOTOS}" CACHE INTERNAL "Does compiler support computed gotos ?")
        tcm_info("Has computed gotos : ${TCM_SUPPORT_COMPUTED_GOTOS}")
    else ()
        tcm_debug("Has computed gotos : ${TCM_SUPPORT_COMPUTED_GOTOS}")
    endif ()

    #-------------------------------------------------------------------------------
    #   Warning Guard
    #
    # target_include_directories with the SYSTEM modifier will request the compiler
    # to omit warnings from the provided paths, if the compiler supports that.
    # This is to provide a user experience similar to find_package when
    # add_subdirectory or FetchContent is used to consume this project
    #
    if(PROJECT_IS_TOP_LEVEL)
        set(TCM_WARNING_GUARD "")
    else()
        option(TCM_INCLUDES_WITH_SYSTEM "Use SYSTEM modifier for shared includes, disabling warnings" ON)
        mark_as_advanced(TCM_INCLUDES_WITH_SYSTEM)
        if(TCM_INCLUDES_WITH_SYSTEM)
            set(TCM_WARNING_GUARD SYSTEM)
        endif()
    endif ()
endmacro()


# ------------------------------------------------------------------------------
# --- SHARED
# ------------------------------------------------------------------------------
include(GenerateExportHeader)

#-------------------------------------------------------------------------------
#   Generate export header for a target
#   Include it like so `<target_name/export.h>`
#   If used for two targets with sames sources, but one static and the other shared,
#   then tcm_target_export_header must be called on both, to properly set defines, with the static one called with BASE_NAME name_of_shared_target.
#   Export macro is : ${arg_BASE_NAME}_API
#
function(tcm_target_export_header arg_TARGET)
    set(one_value_args BASE_NAME)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "" "")

    # Set Default values
    if(NOT DEFINED arg_BASE_NAME)
        set(arg_BASE_NAME ${arg_TARGET})
    endif ()
    set(arg_EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/export/${arg_BASE_NAME}/export.h")
    string(TOUPPER ${arg_BASE_NAME} arg_BASE_NAME_UPPER)

    # Generate export header, even for static library as they need the header to compile
    target_include_directories(${arg_TARGET} SYSTEM PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/export>)

    if(NOT EXISTS ${arg_EXPORT_FILE_NAME})
        # Generate export header, even for static library as they need the header to compile
        generate_export_header(
                ${arg_TARGET}
                BASE_NAME ${arg_BASE_NAME}
                EXPORT_FILE_NAME ${arg_EXPORT_FILE_NAME}
                EXPORT_MACRO_NAME ${arg_BASE_NAME_UPPER}_API
        )
    endif ()

    # Check type instead of BUILD_SHARED_LIBS as a library type could be forced.
    get_target_property(target_type ${arg_TARGET} TYPE)
    if (target_type STREQUAL "STATIC_LIBRARY")
        target_compile_definitions(${arg_TARGET} PUBLIC ${arg_BASE_NAME_UPPER}_STATIC_DEFINE)
        return() # The rest of the function is relevant only for a shared library
    endif ()

    set_target_properties(${arg_TARGET} PROPERTIES
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN YES
            VERSION "${PROJECT_VERSION}"
            SOVERSION "${PROJECT_VERSION_MAJOR}"
            EXPORT_NAME ${arg_TARGET}
            OUTPUT_NAME ${arg_TARGET}
    )

endfunction()



# ------------------------------------------------------------------------------
# --- TOOLS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.
#
macro(tcm__setup_cpm)
    tcm_default_value(CPM_INDENT "(CPM)")
    tcm_default_value(CPM_USE_NAMED_CACHE_DIRECTORIES ON)  # See https://github.com/cpm-cmake/CPM.cmake?tab=readme-ov-file#cpm_use_named_cache_directories
    tcm_default_value(CPM_DOWNLOAD_VERSION 0.40.2)

    if(NOT EXISTS ${CPM_FILE})
        if(CPM_SOURCE_CACHE)
            set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
        elseif(DEFINED ENV{CPM_SOURCE_CACHE})
            set(CPM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
        else()
            set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
        endif()

        # Expand relative path. This is important if the provided path contains a tilde (~)
        file(REAL_PATH ${CPM_DOWNLOAD_LOCATION} CPM_DOWNLOAD_LOCATION)

        if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
            tcm_info("Downloading CPM.cmake to ${CPM_DOWNLOAD_LOCATION}")
            file(DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
                    ${CPM_DOWNLOAD_LOCATION}
                    STATUS DOWNLOAD_STATUS
            )
            list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
            list(GET DOWNLOAD_STATUS 1 ERROR_MESSAGE)
            if(NOT ${STATUS_CODE} EQUAL 0) # Check if download was successful.
                # Exit CMake if the download failed, printing the error message.
                tcm_error("Failed to download CPM.cmake with error ${STATUS_CODE}: ${ERROR_MESSAGE}")
                file(REMOVE ${CPM_DOWNLOAD_LOCATION}) # Prevent empty file if download failed.
            else ()
                tcm_info("CPM: ${CPM_DOWNLOAD_LOCATION}")
            endif()
        endif()
        include(${CPM_DOWNLOAD_LOCATION})
    else ()
        tcm_debug("CPM: ${CPM_FILE}")
        include(${CPM_FILE})
    endif ()
endmacro()

# ------------------------------------------------------------------------------
#   Prevents unimportant messages (below NOTICE) from packages managed by CPM
#
macro(tcm_silence_cpm_package arg_PACKAGE)
    if(CPM_PACKAGE_${arg_PACKAGE}_SOURCE_DIR)
        tcm_silence_message()
    endif ()
endmacro()

# ------------------------------------------------------------------------------
# Description:
#   Setup cache (only if top level project), like ccache (https://ccache.dev/) if available on system.
#
# Usage :
#   tcm_setup_cache()
#
function(tcm__setup_cache)
    if(EMSCRIPTEN) # Doesn't seems to work with emscripten (https://github.com/emscripten-core/emscripten/issues/11974)
        return()
    endif()

    set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
    set(CACHE_OPTION_VALUES "ccache" "sccache")
    set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})

    if(NOT ${CACHE_OPTIONS} IN_LIST CACHE_OPTION_VALUES)
        tcm_warn("Trying to use an unsupported custom compiler cache system: '${CACHE_OPTION}'. Supported entries are ${CACHE_OPTION_VALUES}.")
    endif()

    if(NOT DEFINED CACHE_BINARY)
        find_program(CACHE_BINARY NAMES ${CACHE_OPTION_VALUES})
        if(CACHE_BINARY) # First time setting cache binary
            tcm_info("Cache System: ${CACHE_BINARY}.")
        endif ()
    elseif (CACHE_BINARY) # Already set.
        tcm_debug("Cache System: ${CACHE_BINARY}.")
    endif ()

    if(CACHE_BINARY)
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_C_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_CUDA_COMPILER_LAUNCHER "${CACHE_BINARY}" PARENT_SCOPE)
    else()
        tcm_warn("${CACHE_OPTION} is enabled but was not found. Not using it")
    endif()
endfunction()

# ------------------------------------------------------------------------------
#   FOR INTERNAL USAGE.
# Description:  Setup various tools depending on cache variable `TCM_TOOLS`.
#
macro(tcm__module_tools)
    tcm_default_value(TCM_TOOLS "CPM;CCACHE")

    if(CPM IN_LIST TCM_TOOLS)
        tcm__setup_cpm()
    endif ()

    if(CCACHE IN_LIST TCM_TOOLS)
        tcm__setup_cache()
    endif ()
endmacro()


# ------------------------------------------------------------------------------
# --- SETUP PROJECT VERSION
# ------------------------------------------------------------------------------
# Description:
#   Set project's version using semantic versioning, either from git in dev mode or from version file.
#   Expected to be called from root CMakeLists.txt and from a valid git directory.
#
# Credits:
#   Adapted from https://github.com/nunofachada/cmake-git-semver/blob/master/GetVersionFromGitTag.cmake
#
# Usage :
#   tcm_setup_project_version()
#
function(tcm_setup_project_version)
    find_package(Git QUIET)
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
            set(${PROJECT_NAME}_VERSION_MAJOR "0" PARENT_SCOPE)
            set(PROJECT_VERSION_MAJOR "0" PARENT_SCOPE)
            set(${PROJECT_NAME}_VERSION_MINOR "0" PARENT_SCOPE)
            set(PROJECT_VERSION_MINOR "0" PARENT_SCOPE)
            set(${PROJECT_NAME}_VERSION_PATCH "0" PARENT_SCOPE)
            set(PROJECT_VERSION_PATCH "0" PARENT_SCOPE)
        else()
            string(REPLACE "." ";" PARTIAL_VERSION_LIST ${VERSION_STRING})
            list(LENGTH PARTIAL_VERSION_LIST LIST_LENGTH)

            # Set Major
            list(GET PARTIAL_VERSION_LIST 0 VALUE)
            set(${PROJECT_NAME}_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
            set(PROJECT_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
            set(VERSION ${VALUE})

            #Set Minor
            if(LIST_LENGTH GREATER_EQUAL 2)
                list(GET PARTIAL_VERSION_LIST 1 VALUE)
                set(${PROJECT_NAME}_VERSION_MINOR ${VALUE} PARENT_SCOPE)
                set(PROJECT_VERSION_MINOR ${VALUE} PARENT_SCOPE)
                string(APPEND VERSION ".${VALUE}")
            else ()
                set(${PROJECT_NAME}_VERSION_MINOR 0 PARENT_SCOPE)
                set(PROJECT_VERSION_MINOR 0 PARENT_SCOPE)
                string(APPEND VERSION ".0")
            endif ()

            #Set Patch
            if(LIST_LENGTH GREATER_EQUAL 3)
                list(GET PARTIAL_VERSION_LIST 2 VALUE)
                set(${PROJECT_NAME}_VERSION_PATCH ${VALUE} PARENT_SCOPE)
                set(PROJECT_VERSION_PATCH ${VALUE} PARENT_SCOPE)
                string(APPEND VERSION ".${VALUE}")
            else ()
                set(${PROJECT_NAME}_VERSION_PATCH 0 PARENT_SCOPE)
                set(PROJECT_VERSION_PATCH 0 PARENT_SCOPE)
                string(APPEND VERSION ".0")
            endif ()
        endif()

        set(${PROJECT_NAME}_VERSION ${VERSION} PARENT_SCOPE)
        set(PROJECT_VERSION ${VERSION} PARENT_SCOPE)

        # Save version to file
        file(WRITE ${CMAKE_SOURCE_DIR}/VERSION ${VERSION})

    else()
        # Git not available, get version from file
        file(STRINGS "VERSION" VERSION)
        set(${PROJECT_NAME}_VERSION ${VERSION} PARENT_SCOPE)
        set(PROJECT_VERSION ${VERSION} PARENT_SCOPE)

        string(REPLACE "." ";" VERSION_LIST ${VERSION})
        list(GET VERSION_LIST 0 VALUE)
        set(${PROJECT_NAME}_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
        set(PROJECT_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
        list(GET VERSION_LIST 1 VALUE)
        set(${PROJECT_NAME}_VERSION_MINOR ${VALUE} PARENT_SCOPE)
        set(PROJECT_VERSION_MINOR ${VALUE} PARENT_SCOPE)
        list(GET VERSION_LIST 2 VALUE)
        set(${PROJECT_NAME}_VERSION_PATCH ${VALUE} PARENT_SCOPE)
        set(PROJECT_VERSION_PATCH ${VALUE} PARENT_SCOPE)
    endif()

    tcm_info("Project Version : ${VERSION}")
endfunction()


# ------------------------------------------------------------------------------
# --- MODULE: BENCHMARKS
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Description:
#   Setup benchmarks using google benchmark (with provided main).
#
function(tcm_setup_benchmark)
    set(oneValueArgs GOOGLE_BENCHMARK_VERSION)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_default_value(arg_GOOGLE_BENCHMARK_VERSION "v1.9.1")
    tcm_section("Benchmarks")

    find_package(benchmark QUIET)
    if(NOT benchmark_FOUND)
        tcm_silence_cpm_package(benchmark)
        CPMAddPackage(
                NAME benchmark
                GIT_TAG ${arg_GOOGLE_BENCHMARK_VERSION}
                GITHUB_REPOSITORY google/benchmark
                OPTIONS
                "BENCHMARK_ENABLE_INSTALL OFF"
                "BENCHMARK_ENABLE_INSTALL_DOCS OFF"
                "BENCHMARK_ENABLE_TESTING OFF"
                "BENCHMARK_INSTALL_DOCS OFF"
        )
        tcm_restore_message_log_level()
        if(NOT benchmark_SOURCE_DIR)
            tcm_warn("Couldn't find and install google benchmark (using CPM) --> Skipping benchmark.")
            return()
        endif ()
    endif()
endfunction()


# ------------------------------------------------------------------------------
# Description:
#   Add benchmarks using google benchmark (with provided main).
#
function(tcm_benchmarks)
    set(one_value_args
            NAME
    )
    set(multi_value_args
            FILES
            LIBRARIES
    )
    set(required_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "${multi_value_args}" "${required_args}")
    tcm_default_value(arg_NAME "${PROJECT_NAME}_Benchmarks")

    tcm_setup_benchmark()
    tcm_section("Benchmarks")
    if(NOT TARGET ${arg_NAME})
        tcm_log("Configuring ${arg_NAME}.")
        add_executable(${arg_NAME} ${arg_FILES})
        target_link_libraries(${arg_NAME} PRIVATE benchmark::benchmark_main ${arg_LIBRARIES})
        tcm_target_enable_optimisation_flags(${arg_NAME})
        set_target_properties(${arg_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/benchmarks")
        set_target_properties(${target_name} PROPERTIES FOLDER "Benchmarks")
        tcm_target_copy_assets(${arg_NAME} OUTPUT_DIR "scripts" FILES "${benchmark_SOURCE_DIR}/tools")
        # Copy google benchmark tools : compare.py and its requirements for ease of use
        file(REAL_PATH "${benchmark_SOURCE_DIR}/tools" path)
        add_custom_command(
                TARGET ${arg_NAME}
                POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${path}" "$<TARGET_FILE_DIR:${arg_NAME}>/scripts/google_benchmark_tools"
                VERBATIM
        )
    else ()
        tcm_debug("Adding sources to ${arg_NAME}: ${arg_FILES}.")
        target_sources(${arg_NAME} PRIVATE ${arg_FILES})
    endif ()

endfunction()


# ------------------------------------------------------------------------------
# --- MODULE: TESTS
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Description:
#   Setup tests using Catch2 (with provided main).
#
# Usage :
#   tcm_setup_test([CATCH2_VERSION vX.X.X])
#
function(tcm_setup_test)
    set(oneValueArgs CATCH2_VERSION)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_default_value(arg_CATCH2_VERSION "v3.7.1")
    tcm_section("Tests")

    find_package(Catch2 3 QUIET)
    if(NOT Catch2_FOUND)
        tcm_silence_cpm_package(Catch2)
        CPMAddPackage(
                NAME Catch2
                GIT_TAG ${arg_CATCH2_VERSION}
                GITHUB_REPOSITORY catchorg/Catch2
        )
        tcm_restore_message_log_level()
        if(NOT Catch2_SOURCE_DIR)
            tcm_warn("failed. Couldn't find and install Catch2 (using CPM) --> Skipping tests.")
            return()
        endif ()
        list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)
        include(Catch)
    endif()
endfunction()


# ------------------------------------------------------------------------------
# Description:
#   Add tests using Catch2 (with provided main).
#
# Usage :
#   tcm_tests([NAME <name>] [LIBRARIES <target> ...] FILES your_source.cpp ...)
#
function(tcm_tests)
    set(one_value_args
            NAME
    )
    set(multi_value_args
            FILES
            LIBRARIES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm_default_value(arg_NAME "${PROJECT_NAME}_Tests")

    tcm_setup_test()
    tcm_section("Tests")
    if(NOT TARGET ${arg_NAME})
        tcm_log("Configuring ${arg_NAME}.")
        add_executable(${arg_NAME} ${arg_FILES})
        target_link_libraries(${arg_NAME} PRIVATE Catch2::Catch2WithMain ${arg_LIBRARIES})
        set_target_properties(${arg_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/tests")
        set_target_properties(${target_name} PROPERTIES FOLDER "Tests")
        catch_discover_tests(${arg_NAME})
    else ()
        tcm_debug("Adding sources to ${arg_NAME}: ${arg_FILES}.")
        target_sources(${arg_NAME} PRIVATE ${arg_FILES})
    endif ()

endfunction()


# ------------------------------------------------------------------------------
# --- EXAMPLES
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#   FOR INTERNAL USAGE: used by `tcm_examples`
#
function(tcm__add_example arg_FILE arg_NAME)
    cmake_path(REMOVE_EXTENSION arg_NAME OUTPUT_VARIABLE target_name)

    # Replace the slashes and dots with underscores to get a valid target name
    # (e.g. 'foo_bar_cpp' from 'foo/bar.cpp')
    string(REPLACE "/" "_" target_name ${target_name})

    add_executable(${target_name} ${arg_FILE})
    if(arg_LIBRARIES)
        target_link_libraries(${target_name} PUBLIC ${arg_LIBRARIES})
    endif ()
    set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/examples")
    set_target_properties(${target_name} PROPERTIES FOLDER "Examples")
    add_test(NAME ${target_name} COMMAND ${target_name})

    list(APPEND TARGETS ${target_name})
    set(TARGETS ${TARGETS} PARENT_SCOPE)

    if(NOT arg_WITH_BENCHMARK)
        tcm_log("Configuring example \"${target_name}\"")
        return()
    endif ()

    set(benchmark_file ${CMAKE_CURRENT_BINARY_DIR}/benchmarks/${target_name}.cpp)
    if(${arg_FILE} IS_NEWER_THAN ${benchmark_file})

        file(READ "${arg_FILE}" file_content)

        if(NOT file_content)
            tcm_warn("Example \"${arg_NAME}\" cannot be integrated in a benchmark.")
            tcm_warn("Reason:  could not read file ${arg_FILE}.")
            return()
        endif ()

        string(REGEX MATCH " main[(][)]" can_benchmark "${file_content}")

        if(NOT can_benchmark)
            tcm_warn("Example \"${arg_NAME}\" cannot be integrated in a benchmark.")
            tcm_warn("Reason:  only empty `main()`signature is supported (and with a return value).")
            return()
        endif ()

        string(REGEX REPLACE " main[(]" " ${target_name}_main(" file_content "${file_content}")

        list(APPEND file_content "
#include <benchmark/benchmark.h>

static void BM_example_${target_name}(benchmark::State& state)
{
for (auto _: state)
    {
        ${target_name}_main();
    }
}

BENCHMARK(BM_example_${target_name});
"
        )
        tcm_info("Generating benchmark source file for ${target_name}: ${benchmark_file}")
        file(WRITE ${benchmark_file} "${file_content}")
    endif ()
    if(arg_LIBRARIES)
        tcm_benchmarks(FILES ${benchmark_file} LIBRARIES ${arg_LIBRARIES})
    else ()
        tcm_benchmarks(FILES ${benchmark_file})
    endif ()

    tcm_log("Configuring example \"${target_name}\" (w/ benchmark)")
endfunction()


# ------------------------------------------------------------------------------
# Description:
#   Convenience function to produce examples or a target for each source file (recursive).
#   You shouldn't use it for "complex" examples, where some .cpp files do not provide a main entry point.
#   There is not much to it. Here is what it does:
#       - Each example defines a new target, named : <relative_path_to_examples_folder>_filename
#       - Each example is a test (added to CTest)
#       - Each example executable is outputted to ${TCM_EXE_DIR}/examples.
#       - Each example can be added to a benchmark target with function option `WITH_BENCHMARK`.
#
# Parameters:
#   Take a folder path.
#
# Outputs:
#   ${TCM_EXAMPLE_TARGETS} - List of all examples target __configured during this call !__
#
function(tcm_examples)
    set(options
            WITH_BENCHMARK
    )
    set(one_value_args
            FILES
    )
    set(multi_value_args
            LIBRARIES
    )
    set(required_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "${options}" "${one_value_args}" "${multi_value_args}" "${required_args}")

    tcm_setup_test()
    if(arg_WITH_BENCHMARK)
        tcm_setup_benchmark()
    endif ()

    tcm_section("Examples")

    foreach (item IN LISTS arg_FILES)
        file(REAL_PATH ${item} path)
        if(IS_DIRECTORY ${path})
            list(APPEND folders ${path})
        else ()
            list(APPEND ${item})
        endif ()
    endforeach ()

    foreach (folder IN LISTS folders)
        file (GLOB_RECURSE examples CONFIGURE_DEPENDS RELATIVE ${folder} "${folder}/*.cpp" )
        list(APPEND DOXYGEN_EXAMPLE_PATH ${folder})
        foreach (example IN LISTS examples)
            tcm__add_example(${folder}/${example} ${example})
        endforeach ()
    endforeach ()

    foreach (example IN LISTS files)
        file(REAL_PATH ${example} path)
        list(APPEND DOXYGEN_EXAMPLE_PATH ${path})
        tcm__add_example(${path} ${example})
    endforeach ()

    set(TCM_EXAMPLE_TARGETS ${TARGETS} PARENT_SCOPE)
    set(DOXYGEN_EXAMPLE_PATH ${DOXYGEN_EXAMPLE_PATH} PARENT_SCOPE)
endfunction()


# ------------------------------------------------------------------------------
# --- ISPC
# ------------------------------------------------------------------------------

function(tcm_target_setup_ispc target)
    set(options)
    set(oneValueArgs
            HEADER_DIR
            HEADER_SUFFIX
            INSTRUCTION_SETS
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm_default_value(arg_HEADER_DIR "${CMAKE_CURRENT_BINARY_DIR}/ispc/")
    tcm_default_value(arg_HEADER_SUFFIX ".h")

    set_target_properties(ispc_lib PROPERTIES ISPC_HEADER_DIRECTORY ${arg_HEADER_DIR})
    set_target_properties(ispc_lib PROPERTIES ISPC_HEADER_SUFFIX ${arg_HEADER_SUFFIX})

    if(arg_INSTRUCTION_SETS)
        set_target_properties(ispc_lib PROPERTIES ISPC_INSTRUCTION_SETS ${arg_INSTRUCTION_SETS})
    endif ()

    target_include_directories(ispc_lib PUBLIC $<TARGET_PROPERTY:ISPC_HEADER_DIRECTORY>)
endfunction()


# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   Set default flags for a minimal emscripten setup with some overridable options.
#
function(tcm_target_setup_for_emscripten arg_TARGET)
    if(NOT EMSCRIPTEN)
        return()
    endif ()

    set(one_value_args
            SHELL_FILE      # Override default shell file.
            PRELOAD_DIR     # Preload files inside directory.
            EMBED_DIR       # Embed files inside directory.
    )

    cmake_parse_arguments(PARSE_ARGV 1 arg "" "${one_value_args}" "")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "")

    tcm_default_value(arg_SHELL_FILE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")
    tcm__emscripten_generate_default_shell_file()

    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    target_link_options(${arg_TARGET} PRIVATE --shell-file ${arg_SHELL_FILE})
    target_link_options(${arg_TARGET} PRIVATE -sMAX_WEBGL_VERSION=2 -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=1mb)
    target_link_options(${arg_TARGET} PRIVATE -sEXPORTED_RUNTIME_METHODS=cwrap --no-heap-copy)
    target_link_options(${arg_TARGET} PRIVATE $<IF:$<CONFIG:DEBUG>,-sASSERTIONS=1,-sASSERTIONS=0> -sMALLOC=emmalloc)

    add_custom_target(${arg_TARGET}_open_html COMMAND emrun $<TARGET_FILE:${arg_TARGET}>)
    add_dependencies(${arg_TARGET}_open_html ${arg_TARGET})

    # TODO Needs testing
    if(arg_PRELOAD_DIR)
        target_link_options(${arg_TARGET} PRIVATE --preload-file ${arg_PRELOAD_DIR})
    endif ()

    if(arg_EMBED_DIR)
        target_link_options(${arg_TARGET} PRIVATE --embed-file ${arg_PRELOAD_DIR})
    endif ()

endfunction()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Generate a default html shell file for emscripten.
#
function(tcm__emscripten_generate_default_shell_file)
    if(EMSCRIPTEN)
        set(embed_shell_file "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")
        if(NOT EXISTS ${embed_shell_file})
            tcm_info("(TCM) Generating embedded shell file for emscripten to ${embed_shell_file}.")
            file(WRITE "${embed_shell_file}.in" [=[<!doctype html>
<html lang="en-us">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no"/>
    <title>@PROJECT_NAME@</title>
    <link rel="icon" href="@PROJECT_LOGO@">
    <style>
        body { margin: 0; background-color: black }
        .emscripten {
            position: absolute;
            top: 0px;
            left: 0px;
            margin: 0px;
            border: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            display: block;
            image-rendering: optimizeSpeed;
            image-rendering: -moz-crisp-edges;
            image-rendering: -o-crisp-edges;
            image-rendering: -webkit-optimize-contrast;
            image-rendering: optimize-contrast;
            image-rendering: crisp-edges;
            image-rendering: pixelated;
            -ms-interpolation-mode: nearest-neighbor;
        }
    </style>
</head>
<body>
<canvas class="emscripten" id="canvas" oncontextmenu="event.preventDefault()"></canvas>
<script type='text/javascript'>
    var Module = {
        preRun: [],
        postRun: [],
        print: (function() {
            return function(text) {
                text = Array.prototype.slice.call(arguments).join(' ');
                console.log(text);
            };
        })(),
        printErr: function(text) {
            text = Array.prototype.slice.call(arguments).join(' ');
            console.error(text);
        },
        canvas: (function() {
            var canvas = document.getElementById('canvas');
            //canvas.addEventListener("webglcontextlost", function(e) { alert('FIXME: WebGL context lost, please reload the page'); e.preventDefault(); }, false);
            return canvas;
        })(),
        setStatus: function(text) {
            console.log("status: " + text);
        },
        monitorRunDependencies: function(left) {
            // no run dependencies to log
        }
    };
    window.onerror = function() {
        console.log("onerror: " + event);
    };
</script>
{{{ SCRIPT }}}
</body>
</html>
]=])
        endif ()
        configure_file("${embed_shell_file}.in" ${embed_shell_file} @ONLY)
    endif ()
endfunction()



# ------------------------------------------------------------------------------
# --- SETUP-DOCUMENTATION
# ------------------------------------------------------------------------------
# Description:
#   Setup documentation using doxygen and doxygen-awesome.

function(tcm_documentation)
    set(one_value_args
            DOXYGEN_AWESOME_VERSION
    )
    set(multi_value_args
            FILES
            ASSETS
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "$" "${one_value_args}" "${multi_value_args}" "")

    # ------------------------------------------------------------------------------
    # --- Fail fast if doxygen is not here
    # ------------------------------------------------------------------------------
    tcm_section("Documentation")

    # Doxygen is a documentation generator and static analysis tool for software source trees.
    find_package(Doxygen COMPONENTS dot QUIET)
    if(NOT Doxygen_FOUND)
        tcm_warn("Doxygen not found -> Skipping docs.")
        return()
    endif()


    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm_default_value(arg_DOXYGEN_AWESOME_VERSION      "v2.3.4")
    tcm_default_value(DOXYGEN_USE_MDFILE_AS_MAINPAGE   "${PROJECT_SOURCE_DIR}/README.md")
    tcm_default_value(DOXYGEN_OUTPUT_DIRECTORY         "${CMAKE_CURRENT_BINARY_DIR}/doxygen")
    tcm_default_value(DOXYGEN_HTML_HEADER              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html")
    tcm_default_value(DOXYGEN_HTML_FOOTER              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html")
    tcm_default_value(DOXYGEN_LAYOUT_FILE              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/layout.xml")
    if(DOXYGEN_USE_MDFILE_AS_MAINPAGE)
        list(APPEND arg_FILES ${PROJECT_SOURCE_DIR}/README.md)
    endif ()

    if(NOT EXISTS ${DOXYGEN_HTML_HEADER})
        tcm_info("Generating default html header")
        set(TMP_DOXYGEN_HTML_HEADER "${DOXYGEN_HTML_HEADER}.in")
        file(WRITE ${TMP_DOXYGEN_HTML_HEADER} [=[<!-- HTML header for doxygen 1.9.7-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="$langISO">
<head>
    <meta http-equiv="Content-Type" content="text/xhtml;charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=11" />
    <meta name="generator" content="Doxygen $doxygenversion" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!--BEGIN PROJECT_NAME-->
    <title>$projectname: $title</title><!--END PROJECT_NAME-->
    <!--BEGIN !PROJECT_NAME-->
    <title>$title</title><!--END !PROJECT_NAME-->
    <link href="$relpath^tabs.css" rel="stylesheet" type="text/css" />
    <!--BEGIN DISABLE_INDEX-->
    <!--BEGIN FULL_SIDEBAR-->
    <script type="text/javascript">var page_layout = 1;</script>
    <!--END FULL_SIDEBAR-->
    <!--END DISABLE_INDEX-->
    <script type="text/javascript" src="$relpath^jquery.js"></script>
    <script type="text/javascript" src="$relpath^dynsections.js"></script>
    $treeview
    $search
    $mathjax
    $darkmode
    <link href="$relpath^$stylesheet" rel="stylesheet" type="text/css" />
    $extrastylesheet
    <!--Reference: https://jothepro.github.io/doxygen-awesome-css/md_docs_2extensions.html -->
    <script type="text/javascript" src="$relpath^doxygen-awesome-darkmode-toggle.js"></script>
    <script type="text/javascript" src="$relpath^doxygen-awesome-fragment-copy-button.js"></script>
    <script type="text/javascript" src="$relpath^doxygen-awesome-paragraph-link.js"></script>
    <script type="text/javascript" src="$relpath^doxygen-awesome-interactive-toc.js"></script>
    <script type="text/javascript" src="$relpath^doxygen-awesome-tabs.js"></script>
    <script type="text/javascript">
        DoxygenAwesomeDarkModeToggle.init()
        DoxygenAwesomeFragmentCopyButton.init()
        DoxygenAwesomeParagraphLink.init()
        DoxygenAwesomeInteractiveToc.init()
        DoxygenAwesomeTabs.init()
    </script>
    <!--Fonts-->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto&display=swap" rel="stylesheet">
</head>
<body>
    <!-- https://tholman.com/github-corners/ -->
    <a href="@PROJECT_HOMEPAGE_URL@" class="github-corner" title="View source on GitHub" target="_blank" rel="noopener noreferrer">
    <svg viewBox="0 0 250 250" width="40" height="40" style="position: absolute; top: 0; border: 0; right: 0; z-index: 99;" aria-hidden="true">
    <path d="M0,0 L115,115 L130,115 L142,142 L250,250 L250,0 Z"></path><path d="M128.3,109.0 C113.8,99.7 119.0,89.6 119.0,89.6 C122.0,82.7 120.5,78.6 120.5,78.6 C119.2,72.0 123.4,76.3 123.4,76.3 C127.3,80.9 125.5,87.3 125.5,87.3 C122.9,97.6 130.6,101.9 134.4,103.2" fill="currentColor" style="transform-origin: 130px 106px;" class="octo-arm"></path><path d="M115.0,115.0 C114.9,115.1 118.7,116.5 119.8,115.4 L133.7,101.6 C136.9,99.2 139.9,98.4 142.2,98.6 C133.8,88.0 127.5,74.4 143.8,58.0 C148.5,53.4 154.0,51.2 159.7,51.0 C160.3,49.4 163.2,43.6 171.4,40.1 C171.4,40.1 176.1,42.5 178.8,56.2 C183.1,58.6 187.2,61.8 190.9,65.4 C194.5,69.0 197.7,73.2 200.1,77.6 C213.8,80.2 216.3,84.9 216.3,84.9 C212.7,93.1 206.9,96.0 205.4,96.6 C205.1,102.4 203.0,107.8 198.3,112.5 C181.9,128.9 168.3,122.5 157.7,114.1 C157.9,116.9 156.7,120.9 152.7,124.9 L141.0,136.5 C139.8,137.7 141.6,141.9 141.8,141.8 Z" fill="currentColor" class="octo-body"></path></svg></a><style>.github-corner:hover .octo-arm{animation:octocat-wave 560ms ease-in-out}@keyframes octocat-wave{0%,100%{transform:rotate(0)}20%,60%{transform:rotate(-25deg)}40%,80%{transform:rotate(10deg)}}@media (max-width:500px){.github-corner:hover .octo-arm{animation:none}.github-corner .octo-arm{animation:octocat-wave 560ms ease-in-out}}</style>

    <!--BEGIN DISABLE_INDEX-->


    <!--BEGIN FULL_SIDEBAR-->
    <div id="side-nav" class="ui-resizable side-nav-resizable">
        <!-- do not remove this div, it is closed by doxygen! -->
        <!--END FULL_SIDEBAR-->
        <!--END DISABLE_INDEX-->

        <div id="top">
            <!-- do not remove this div, it is closed by doxygen! -->
            <!--BEGIN TITLEAREA-->
            <div id="titlearea">
                <table cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr id="projectrow">
                            <!--BEGIN PROJECT_LOGO-->
                            <td id="projectlogo"><img alt="Logo" src="$relpath^$projectlogo" /></td>
                            <!--END PROJECT_LOGO-->
                            <!--BEGIN PROJECT_NAME-->
                            <td id="projectalign">
                                <div id="projectname">
                                    $projectname<!--BEGIN PROJECT_NUMBER--><span id="projectnumber">&#160;$projectnumber</span><!--END PROJECT_NUMBER-->
                                </div>
                                <!--BEGIN PROJECT_BRIEF--><div id="projectbrief">$projectbrief</div><!--END PROJECT_BRIEF-->
                            </td>
                            <!--END PROJECT_NAME-->
                            <!--BEGIN !PROJECT_NAME-->
                            <!--BEGIN PROJECT_BRIEF-->
                            <td>
                                <div id="projectbrief">$projectbrief</div>
                            </td>
                            <!--END PROJECT_BRIEF-->
                            <!--END !PROJECT_NAME-->
                            <!--BEGIN DISABLE_INDEX-->
                            <!--BEGIN SEARCHENGINE-->
                            <!--BEGIN !FULL_SIDEBAR-->
                            <td>$searchbox</td>
                            <!--END !FULL_SIDEBAR-->
                            <!--END SEARCHENGINE-->
                            <!--END DISABLE_INDEX-->
                        </tr>
                        <!--BEGIN SEARCHENGINE-->
                        <!--BEGIN FULL_SIDEBAR-->
                        <tr><td colspan="2">$searchbox</td></tr>
                        <!--END FULL_SIDEBAR-->
                        <!--END SEARCHENGINE-->
                    </tbody>
                </table>
            </div>
            <!--END TITLEAREA-->
            <!-- end header part -->
]=])
        configure_file(${TMP_DOXYGEN_HTML_HEADER} ${DOXYGEN_HTML_HEADER})
    endif ()

    if(NOT EXISTS ${DOXYGEN_HTML_FOOTER})
        tcm_info("Generating default html footer")
        set(TMP_DOXYGEN_HTML_FOOTER "${DOXYGEN_HTML_FOOTER}.in")
        file(WRITE ${TMP_DOXYGEN_HTML_FOOTER} [=[<!-- HTML footer for doxygen 1.9.8-->
<!-- start footer part -->
<!--BEGIN GENERATE_TREEVIEW-->
<div id="nav-path" class="navpath"><!-- id is needed for treeview function! -->
  <ul>
    $navpath
    <li class="footer">$generatedby <a href="https://www.doxygen.org/index.html"><img class="footer" src="$relpath^doxygen.svg" width="104" height="31" alt="doxygen"/></a> $doxygenversion
    and with <a href="https://github.com/jothepro/doxygen-awesome-css/">Doxygen Awesome CSS</a>.
      </li>
  </ul>
</div>
<!--END GENERATE_TREEVIEW-->
<!--BEGIN !GENERATE_TREEVIEW-->
<hr class="footer"/><address class="footer"><small>
$generatedby&#160;<a href="https://www.doxygen.org/index.html"><img class="footer" src="$relpath^doxygen.svg" width="104" height="31" alt="doxygen"/></a> $doxygenversion
    with <a href="https://github.com/jothepro/doxygen-awesome-css/">Doxygen Awesome CSS</a>.
</small></address>
<!--END !GENERATE_TREEVIEW-->
</body>
</html>
]=])
        configure_file(${TMP_DOXYGEN_HTML_FOOTER} ${DOXYGEN_HTML_FOOTER})
    endif ()

    if(NOT EXISTS ${DOXYGEN_LAYOUT_FILE})
        tcm_info("Generating default layout file")
        file(WRITE ${DOXYGEN_LAYOUT_FILE} [=[<?xml version="1.0" encoding="UTF-8"?>
<doxygenlayout version="1.0">
  <navindex>
    <tab type="mainpage" visible="yes" title=""/>

    <tab type="topics" visible="yes" title="Features" intro=""/>

    <tab type="usergroup" visible="yes" title="Handbook" intro="">
      <tab type="pages" visible="yes" title="" intro=""/>
    </tab>

    <tab type="examples" visible="yes" title="Examples" intro=""/>

    <tab type="usergroup" visible="yes" title="Reference" intro="">
      <tab type="modules" visible="yes" title="" intro="">
        <tab type="modulelist" visible="yes" title="" intro=""/>
        <tab type="modulemembers" visible="yes" title="" intro=""/>
      </tab>
      <tab type="namespaces" visible="yes" title="">
        <tab type="namespacelist" visible="yes" title="" intro=""/>
        <tab type="namespacemembers" visible="yes" title="" intro=""/>
      </tab>
      <tab type="concepts" visible="yes" title="">
      </tab>
      <tab type="interfaces" visible="yes" title="">
        <tab type="interfacelist" visible="yes" title="" intro=""/>
        <tab type="interfaceindex" visible="$ALPHABETICAL_INDEX" title=""/>
        <tab type="interfacehierarchy" visible="yes" title="" intro=""/>
      </tab>
      <tab type="classes" visible="yes" title="">
        <tab type="classlist" visible="yes" title="" intro=""/>
        <tab type="classindex" visible="$ALPHABETICAL_INDEX" title=""/>
        <tab type="hierarchy" visible="yes" title="" intro=""/>
        <tab type="classmembers" visible="yes" title="" intro=""/>
      </tab>
      <tab type="structs" visible="yes" title="">
        <tab type="structlist" visible="yes" title="" intro=""/>
        <tab type="structindex" visible="$ALPHABETICAL_INDEX" title=""/>
      </tab>
      <tab type="exceptions" visible="yes" title="">
        <tab type="exceptionlist" visible="yes" title="" intro=""/>
        <tab type="exceptionindex" visible="$ALPHABETICAL_INDEX" title=""/>
        <tab type="exceptionhierarchy" visible="yes" title="" intro=""/>
      </tab>
      <tab type="files" visible="yes" title="">
        <tab type="filelist" visible="yes" title="" intro=""/>
        <tab type="globals" visible="yes" title="" intro=""/>
      </tab>
    </tab>
  </navindex>

  <!-- Layout definition for a class page -->
  <class>
    <briefdescription visible="yes"/>
    <includes visible="$SHOW_HEADERFILE"/>
    <inheritancegraph visible="$CLASS_GRAPH"/>
    <collaborationgraph visible="yes"/>
    <memberdecl>
      <nestedclasses visible="yes" title=""/>
      <publictypes title=""/>
      <services title=""/>
      <interfaces title=""/>
      <publicslots title=""/>
      <signals title=""/>
      <publicmethods title=""/>
      <publicstaticmethods title=""/>
      <publicattributes title=""/>
      <publicstaticattributes title=""/>
      <protectedtypes title=""/>
      <protectedslots title=""/>
      <protectedmethods title=""/>
      <protectedstaticmethods title=""/>
      <protectedattributes title=""/>
      <protectedstaticattributes title=""/>
      <packagetypes title=""/>
      <packagemethods title=""/>
      <packagestaticmethods title=""/>
      <packageattributes title=""/>
      <packagestaticattributes title=""/>
      <properties title=""/>
      <events title=""/>
      <privatetypes title=""/>
      <privateslots title=""/>
      <privatemethods title=""/>
      <privatestaticmethods title=""/>
      <privateattributes title=""/>
      <privatestaticattributes title=""/>
      <friends title=""/>
      <related title="" subtitle=""/>
      <membergroups visible="yes"/>
    </memberdecl>
    <detaileddescription title=""/>
    <memberdef>
      <inlineclasses title=""/>
      <typedefs title=""/>
      <enums title=""/>
      <services title=""/>
      <interfaces title=""/>
      <constructors title=""/>
      <functions title=""/>
      <related title=""/>
      <variables title=""/>
      <properties title=""/>
      <events title=""/>
    </memberdef>
    <allmemberslink visible="yes"/>
    <usedfiles visible="$SHOW_USED_FILES"/>
    <authorsection visible="yes"/>
  </class>

  <!-- Layout definition for a namespace page -->
  <namespace>
    <briefdescription visible="yes"/>
    <memberdecl>
      <nestednamespaces visible="yes" title=""/>
      <constantgroups visible="yes" title=""/>
      <interfaces visible="yes" title=""/>
      <classes visible="yes" title=""/>
      <concepts visible="yes" title=""/>
      <structs visible="yes" title=""/>
      <exceptions visible="yes" title=""/>
      <typedefs title=""/>
      <sequences title=""/>
      <dictionaries title=""/>
      <enums title=""/>
      <functions title=""/>
      <variables title=""/>
      <membergroups visible="yes"/>
    </memberdecl>
    <detaileddescription title=""/>
    <memberdef>
      <inlineclasses title=""/>
      <typedefs title=""/>
      <sequences title=""/>
      <dictionaries title=""/>
      <enums title=""/>
      <functions title=""/>
      <variables title=""/>
    </memberdef>
    <authorsection visible="yes"/>
  </namespace>

  <!-- Layout definition for a concept page -->
  <concept>
    <briefdescription visible="yes"/>
    <includes visible="$SHOW_HEADERFILE"/>
    <definition visible="yes" title=""/>
    <detaileddescription title=""/>
    <authorsection visible="yes"/>
  </concept>

  <!-- Layout definition for a file page -->
  <file>
    <briefdescription visible="yes"/>
    <includes visible="$SHOW_INCLUDE_FILES"/>
    <includegraph visible="yes"/>
    <includedbygraph visible="yes"/>
    <sourcelink visible="yes"/>
    <memberdecl>
      <interfaces visible="yes" title=""/>
      <classes visible="yes" title=""/>
      <structs visible="yes" title=""/>
      <exceptions visible="yes" title=""/>
      <namespaces visible="yes" title=""/>
      <concepts visible="yes" title=""/>
      <constantgroups visible="yes" title=""/>
      <defines title=""/>
      <typedefs title=""/>
      <sequences title=""/>
      <dictionaries title=""/>
      <enums title=""/>
      <functions title=""/>
      <variables title=""/>
      <membergroups visible="yes"/>
    </memberdecl>
    <detaileddescription title=""/>
    <memberdef>
      <inlineclasses title=""/>
      <defines title=""/>
      <typedefs title=""/>
      <sequences title=""/>
      <dictionaries title=""/>
      <enums title=""/>
      <functions title=""/>
      <variables title=""/>
    </memberdef>
    <authorsection/>
  </file>

  <!-- Layout definition for a group page -->
  <group>
    <briefdescription visible="yes"/>
    <groupgraph visible="yes"/>
    <memberdecl>
      <nestedgroups visible="yes" title=""/>
      <modules visible="yes" title=""/>
      <dirs visible="yes" title=""/>
      <files visible="yes" title=""/>
      <namespaces visible="yes" title=""/>
      <concepts visible="yes" title=""/>
      <classes visible="yes" title=""/>
      <defines title=""/>
      <typedefs title=""/>
      <sequences title=""/>
      <dictionaries title=""/>
      <enums title=""/>
      <enumvalues title=""/>
      <functions title=""/>
      <variables title=""/>
      <signals title=""/>
      <publicslots title=""/>
      <protectedslots title=""/>
      <privateslots title=""/>
      <events title=""/>
      <properties title=""/>
      <friends title=""/>
      <membergroups visible="yes"/>
    </memberdecl>
    <detaileddescription title=""/>
    <memberdef>
      <pagedocs/>
      <inlineclasses title=""/>
      <defines title=""/>
      <typedefs title=""/>
      <sequences title=""/>
      <dictionaries title=""/>
      <enums title=""/>
      <enumvalues title=""/>
      <functions title=""/>
      <variables title=""/>
      <signals title=""/>
      <publicslots title=""/>
      <protectedslots title=""/>
      <privateslots title=""/>
      <events title=""/>
      <properties title=""/>
      <friends title=""/>
    </memberdef>
    <authorsection visible="yes"/>
  </group>

  <!-- Layout definition for a C++20 module page -->
  <module>
    <briefdescription visible="yes"/>
    <exportedmodules visible="yes"/>
    <memberdecl>
      <concepts visible="yes" title=""/>
      <classes visible="yes" title=""/>
      <enums title=""/>
      <typedefs title=""/>
      <functions title=""/>
      <variables title=""/>
      <membergroups title=""/>
    </memberdecl>
    <detaileddescription title=""/>
    <memberdecl>
      <files visible="yes"/>
    </memberdecl>
  </module>

  <!-- Layout definition for a directory page -->
  <directory>
    <briefdescription visible="yes"/>
    <directorygraph visible="yes"/>
    <memberdecl>
      <dirs visible="yes"/>
      <files visible="yes"/>
    </memberdecl>
    <detaileddescription title=""/>
  </directory>
</doxygenlayout>
]=])
    endif ()

    if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css")
        tcm_info("Generating custom css.")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css" [=[/* See references :
    * https://jothepro.github.io/doxygen-awesome-css/md_docs_2customization.html 
    * https://github.com/jothepro/doxygen-awesome-css/blob/main/doxygen-custom/custom.css
*/

html {
    /* override light-mode variables here */
    --top-nav-height: 150px;
    --font-family: 'Roboto',-apple-system,BlinkMacSystemFont,Segoe UI,Oxygen,Ubuntu,Cantarell,Fira Sans,Droid Sans,Helvetica Neue,sans-serif;
}

html.dark-mode {
    /* override dark-mode variables here */
}

iframe {
    border-width: 0;
}

.github-corner svg {
    fill: var(--primary-light-color);
    color: var(--page-background-color);
    width: 72px;
    height: 72px;
}

@media screen and (max-width: 767px) {
    /* Possible fix for long description overlapping with side nav */
    /* https://github.com/jothepro/doxygen-awesome-css/issues/129 */
    /* BEGIN */
    #top {
        height: var(--top-nav-height);
    }

    #nav-tree, #side-nav {
        height: calc(100vh - var(--top-nav-height)) !important;
    }

    #side-nav {
        top: var(--top-nav-height);
    }
    /* END */

    .github-corner svg {
        width: 50px;
        height: 50px;
    }
    #projectnumber {
        margin-right: 22px;
    }
}

.alter-theme-button {
    display: inline-block;
    cursor: pointer;
    background: var(--primary-color);
    color: var(--page-background-color) !important;
    border-radius: var(--border-radius-medium);
    padding: var(--spacing-small) var(--spacing-medium);
    text-decoration: none;
}

.alter-theme-button:hover {
    background: var(--primary-dark-color);
}

html.dark-mode .darkmode_inverted_image img, /* < doxygen 1.9.3 */
html.dark-mode .darkmode_inverted_image object[type="image/svg+xml"] /* doxygen 1.9.3 */ {
    filter: brightness(89%) hue-rotate(180deg) invert();
}

.bordered_image {
    border-radius: var(--border-radius-small);
    border: 1px solid var(--separator-color);
    display: inline-block;
    overflow: hidden;
}

html.dark-mode .bordered_image img, /* < doxygen 1.9.3 */
html.dark-mode .bordered_image object[type="image/svg+xml"] /* doxygen 1.9.3 */ {
    border-radius: var(--border-radius-small);
}

.title_screenshot {
    filter: drop-shadow(0px 3px 10px rgba(0,0,0,0.22));
    max-width: 500px;
    margin: var(--spacing-large) 0;
}

.title_screenshot .caption {
    display: none;
}

/* From : https://github.com/SanderMertens/flecs/blob/master/docs/cfg/custom.css */
#projectlogo img {
    max-height: calc(var(--title-font-size) * 1.5) !important;
}

html.light-mode #projectlogo img {
    content: url(logo_small.png);
}
]=])
    endif()

    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------


    # Doxygen awesome CSS is a custom CSS theme for doxygen html-documentation with lots of customization parameters.
    tcm_silence_cpm_package(DOXYGEN_AWESOME_CSS)
    CPMAddPackage(
            NAME DOXYGEN_AWESOME_CSS
            GIT_TAG ${arg_DOXYGEN_AWESOME_VERSION}
            GITHUB_REPOSITORY jothepro/doxygen-awesome-css
    )
    tcm_restore_message_log_level()
    if(NOT DOXYGEN_AWESOME_CSS_SOURCE_DIR)
        tcm_warn("Could not add DOXYGEN_AWESOME_CSS -> Skipping docs.")
        return()
    endif()


    # ------------------------------------------------------------------------------
    # --- Mandatory Doxyfile.in settings
    # ------------------------------------------------------------------------------
    # --- Required by doxygen-awesome-css
    set(DOXYGEN_GENERATE_TREEVIEW YES)
    set(DOXYGEN_DISABLE_INDEX NO)
    set(DOXYGEN_FULL_SIDEBAR NO)
    set(DOXYGEN_HTML_COLORSTYLE	LIGHT) # required with Doxygen >= 1.9.5

    # --- DOT Graphs
    # Reference : https://jothepro.github.io/doxygen-awesome-css/md_docs_2tricks.html
    #(set DOXYGEN_HAVE_DOT YES) # Set to YES if the dot component was requested and found during FindPackage call.
    set(DOXYGEN_DOT_IMAGE_FORMAT svg)
    #set(DOT_TRANSPARENT YES) # Doxygen 1.9.8 report this line as obsolete

    # NOTE : As specified by docs, list will be properly handled by doxygen_add_docs : https://cmake.org/cmake/help/latest/module/FindDoxygen.html
    list(APPEND DOXYGEN_HTML_EXTRA_FILES
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-darkmode-toggle.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-fragment-copy-button.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-paragraph-link.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-interactive-toc.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-tabs.js"
    )

    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome.css"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only.css"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css"
            "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css"
    )

    list(APPEND DOXYGEN_ALIASES
            [[html_frame{1}="@htmlonly<iframe src=\"\1\"></iframe>@endhtmlonly"]]
            [[html_frame{3}="@htmlonly<iframe src=\"\1\" width=\"\2\" height=\"\3\"></iframe>@endhtmlonly"]]
            [[widget{2}="@htmlonly<div class=\"\1\" id=\"\2\"></div>@endhtmlonly"]]
            [[Doxygen="[Doxygen](https://www.doxygen.nl/index.html)"]]
            [[Doxygen-awesome="[Doxygen Awesome CSS](https://jothepro.github.io/doxygen-awesome-css/)"]]
    )
    list(APPEND DOXYGEN_VERBATIM_VARS DOXYGEN_ALIASES)

    foreach (item IN LISTS arg_ASSETS)
        file(REAL_PATH ${item} path)
        list(APPEND DOXYGEN_IMAGE_PATH ${path})
        list(APPEND DOXYGEN_IMAGE_PATH ${path})
    endforeach ()

    # ------------------------------------------------------------------------------
    # --- CONFIGURATION
    # ------------------------------------------------------------------------------
    tcm_log("Configuring ${PROJECT_NAME}_Documentation.")
    doxygen_add_docs(${PROJECT_NAME}_Documentation ${arg_FILES})

    # Utility target to open docs
    add_custom_target(${PROJECT_NAME}_Documentation_Open COMMAND "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html")
    set_target_properties(${target_name} PROPERTIES FOLDER "Utility")
    add_dependencies(${PROJECT_NAME}_Documentation_Open ${PROJECT_NAME}_Documentation)

endfunction()


# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------
tcm__module_logging()

set_property(GLOBAL PROPERTY TCM_INITIALIZED true)
set(TCM_FILE "${CMAKE_CURRENT_LIST_FILE}" CACHE INTERNAL "")
if(NOT DEFINED TCM_VERSION)
    set(TCM_VERSION 1.1.0 CACHE INTERNAL "")
    tcm_info("TCM Version: ${TCM_VERSION}")
endif ()

tcm__module_variables()
tcm__module_tools()


