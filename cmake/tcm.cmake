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
#   For more details about a mixin, see related cmake file.
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.26) # Required for `copy_directory_if_different`.

# ------------------------------------------------------------------------------
# --- OPTIONS
# ------------------------------------------------------------------------------

option(TCM_VERBOSE "Verbose messages during CMake runs"         ${PROJECT_IS_TOP_LEVEL})


# ------------------------------------------------------------------------------
# --- LOGGING
# ------------------------------------------------------------------------------
# This module defines functions/macros for logging purposes in CMake.
# They are simple wrappers over `message()`, whom are mostly noop when current project is not top level.

macro(tcm_indent)
    list(APPEND CMAKE_MESSAGE_INDENT "    ")
endmacro()

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


# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   For internal usage.
#   Convenience macro to ensure target is set either as first argument or with `TARGET` keyword.
#
function(tcm__ensure_target)
    if((NOT arg_TARGET) AND (NOT ARGV0))    # A target must be specified
        tcm_warn(AUTHOR_WARNING "Missing target. Needs to be either first argument or specified with keyword `TARGET`.")
    elseif(NOT arg_TARGET AND ARGV0)        # If not using TARGET, then put ARGV0 as target
        if(NOT TARGET ${ARGV0})             # Make sur that ARGV0 is a target
            tcm_warn(AUTHOR_WARNING "Missing target. Keyword TARGET is missing and first argument \"${ARGV0}\" is not a target.")
        endif()
        set(arg_TARGET ${ARGV0} PARENT_SCOPE)
    endif ()
endfunction()

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
#   Define "-D${arg_OPTION}" for arg_TARGET when arg_OPTION is ON.
#
function(tcm_target_options arg_TARGET)
    set(multi_value_args OPTIONS)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "" "${multi_value_args}")
    foreach (item IN LISTS arg_OPTIONS)
        if (${item})
            target_compile_definitions(${arg_TARGET} PUBLIC "${item}")
        endif ()
    endforeach ()
endfunction()

#-------------------------------------------------------------------------------
#   Post-build, copy files and folder to an asset/ folder inside target's output directory.
#
function(tcm_target_copy_assets)
    set(one_value_args
            OUTPUT_DIR
    )
    set(multi_value_args
            FILES
            FOLDERS
    )
    cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

    if(arg_FILES)
        # Convert files to absolute path.
        foreach (item IN LISTS arg_FILES)
            file(REAL_PATH ${item} path)
            list(APPEND files ${path})
        endforeach ()

        # copy_if_different requires destination folder to exists.
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory "$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                COMMENT "Making directory $<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                VERBATIM
        )
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                #OUTPUT ${SHADER_HEADER}
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${files} "$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                #DEPENDS ${SHADER}
                COMMENT "Copying files [${files}] to $<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>."
                VERBATIM
        )
    endif ()

    if(arg_FOLDERS)
        # Convert folders to absolute path.
        foreach (item IN LISTS arg_FOLDERS)
            file(REAL_PATH ${item} path)
            list(APPEND folders ${path})
        endforeach ()

        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                #OUTPUT ${SHADER_HEADER}
                COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different ${folders} "$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                #DEPENDS ${SHADER}
                COMMENT "Copying directories [${folders}] to $<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>."
                VERBATIM
        )
    endif ()
endfunction()

#-------------------------------------------------------------------------------
#   Disallow in-source builds
#   Not recommended, you should still do it, as it should be called as early as possible, before installing tcm.
#   From : https://github.com/friendlyanon/cmake-init/
#
function(tcm_prevent_in_source_build)
    if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
        tcm_error("In-source builds are not allowed. Please create a separate build directory and run cmake from there" FATAL)
    endif()
endfunction()

#-------------------------------------------------------------------------------
#   Enable optimisation flags on release builds for arg_TARGET
#
function(tcm_target_enable_optimisation arg_TARGET)
    if(TCM_EMSCRIPTEN)
        target_compile_options(${arg_TARGET} PUBLIC "-Os")
        target_link_options(${arg_TARGET} PUBLIC "-Os")

    elseif (TCM_CLANG OR TCM_APPLE_CLANG OR TCM_GCC)
        target_compile_options(${arg_TARGET} PRIVATE
                $<$<CONFIG:RELEASE>:-O3>
                $<$<CONFIG:RELEASE>:-flto>
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
function(tcm_target_enable_warnings arg_TARGET)
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
#   Set a default _value to a _var if not defined.
#
macro(tcm__default_value arg_VAR arg_VALUE)
    if(NOT DEFINED ${arg_VAR})
        set(${arg_VAR} ${arg_VALUE})
    endif ()
endmacro()


# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------
#   For internal usage.
#   Set some useful CMake variables.
#
macro(tcm__setup_variables)
    tcm__default_value(TCM_EXE_DIR "${CMAKE_CURRENT_BINARY_DIR}/bin")

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
    try_compile(TCM_SUPPORT_COMPUTED_GOTOS SOURCE_FROM_CONTENT computed_goto_test.c "int main() { static void* labels[] = {&&label1, &&label2}; int i = 0; goto *labels[i]; label1: return 0; label2: return 1; } ")
    tcm_debug("Feature support - computed gotos : ${TCM_SUPPORT_COMPUTED_GOTOS}")

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
        option(TCM_INCLUDES_WITH_SYSTEM "Use SYSTEM modifier for shared's includes, disabling warnings" ON)
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
#   Generate export header for a target.
#   Export header directory will be included in a private scope.
#
function(tcm_generate_export_header target)
    set(options)
    set(oneValueArgs)
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm__default_value(arg_EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/export/${target}/export.h")

    generate_export_header(
            ${target}
            EXPORT_FILE_NAME ${arg_EXPORT_FILE_NAME}
    )

    string(TOUPPER ${target} UPPER_NAME)
    if(NOT BUILD_SHARED_LIBS)
        target_compile_definitions(${target} PUBLIC ${UPPER_NAME}_STATIC_DEFINE)
    endif()


    set_target_properties(${target} PROPERTIES
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN YES
            VERSION "${PROJECT_VERSION}"
            SOVERSION "${PROJECT_VERSION_MAJOR}"
            EXPORT_NAME ${target}
            OUTPUT_NAME ${target}
    )

    target_include_directories(${target} SYSTEM PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/export>)
endfunction()



# ------------------------------------------------------------------------------
# --- SETUP CPM
# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.
#
macro(tcm_setup_cpm)
    set(CPM_INDENT "(CPM) ")
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
# --- SETUP-CACHE
# ------------------------------------------------------------------------------
# Description:
#   Setup cache (only if top level project), like ccache (https://ccache.dev/) if available on system.

# Usage :
#   tcm_setup_cache()
#
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

    tcm_log("Project Version : ${VERSION}")
endfunction()


# ------------------------------------------------------------------------------
# --- ADD BENCHMARKS
# ------------------------------------------------------------------------------
# Description:
#   Add benchmarks using google benchmark (with provided main).

# Usage :
#   tcm_add_benchmarks(TARGET your_target FILES your_source.cpp ...)
#
function(tcm_add_benchmarks)
    set(options)
    set(oneValueArgs
            TARGET
            GOOGLE_BENCHMARK_VERSION
    )
    set(multiValueArgs
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_section("BENCH")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(arg_GOOGLE_BENCHMARK_VERSION "v1.9.1")


    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    find_package(benchmark QUIET)
    if(NOT benchmark_FOUND OR benchmark_ADDED)
        CPMAddPackage(
                NAME benchmark
                GIT_TAG ${arg_GOOGLE_BENCHMARK_VERSION}
                GITHUB_REPOSITORY google/benchmark
                OPTIONS
                "BENCHMARK_ENABLE_INSTALL_DOCS OFF"
                "BENCHMARK_ENABLE_TESTING OFF"
                "BENCHMARK_INSTALL_DOCS OFF"
        )
        if(NOT benchmark_ADDED)
            tcm_warn("Couldn't found and install google benchmark (using CPM) --> Skipping benchmark.")
            return()
        endif ()
    endif()


    # ------------------------------------------------------------------------------
    # --- Target
    # ------------------------------------------------------------------------------
    add_executable(${arg_TARGET} ${arg_FILES})
    target_link_libraries(${arg_TARGET} PRIVATE benchmark::benchmark_main)
    set_target_properties(${arg_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}")

    # Copy google benchmark tools : compare.py and its requirements for ease of use
    add_custom_command(TARGET ${arg_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory
            "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
    )

    add_custom_command(TARGET ${arg_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${benchmark_SOURCE_DIR}/tools" "${TCM_EXE_DIR}/scripts/google_benchmark_tools"
    )

    tcm_section_end()
endfunction()


# ------------------------------------------------------------------------------
# --- ADD TESTS
# ------------------------------------------------------------------------------
# Description:
#   Add tests using Catch2 (with provided main).
#
# Usage :
#   tcm_add_benchmarks(TARGET your_target FILES your_source.cpp ...)
#
function(tcm_add_tests)
    set(options)
    set(oneValueArgs
            TARGET
            CATCH2_VERSION
    )
    set(multiValueArgs
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_section("TESTS")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(arg_CATCH2_VERSION "v3.7.1")


    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    find_package(Catch2 3 QUIET)

    if(NOT Catch2_FOUND OR Catch2_ADDED)
        CPMAddPackage(
                NAME Catch2
                GIT_TAG ${arg_CATCH2_VERSION}
                GITHUB_REPOSITORY catchorg/Catch2
        )
        if(NOT Catch2_ADDED)
            tcm_warn("Couldn't found and install Catch2 (using CPM) --> Skipping tests.")
            return()
        endif ()
    endif()


    # ------------------------------------------------------------------------------
    # --- Target
    # ------------------------------------------------------------------------------
    add_executable(${arg_TARGET} ${arg_FILES})
    target_link_libraries(${arg_TARGET} PRIVATE Catch2::Catch2WithMain)
    set_target_properties(${arg_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}")

    list(APPEND CMAKE_MODULE_PATH ${Catch2_SOURCE_DIR}/extras)
    include(Catch)
    catch_discover_tests(${arg_TARGET})

    tcm_section_end()
endfunction()


# ------------------------------------------------------------------------------
# --- ADD EXAMPLES
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
# Usage :
#   tcm_add_examples(FOLDER examples/)
#
# TODO:
#   * Pass a INTERFACE target for examples and benchmarks (or add necessary properties after the call)
#   * Only one call should work for WITH_BENCHMARK (only one target). Solution : re use it (cache it)
#
#
function(tcm_add_examples)
    set(options WITH_BENCHMARK)
    set(oneValueArgs
            FOLDER
            GOOGLE_BENCHMARK_VERSION
            INTERFACE
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")
    tcm_section("EXAMPLES")

    if(arg_WITH_BENCHMARK)
        if(NOT TARGET Benchmark_Examples)
            add_executable(Benchmark_Examples)
            target_link_libraries(Benchmark_Examples PRIVATE benchmark::benchmark_main)
            tcm_target_enable_optimisation(Benchmark_Examples)
        endif ()

        if(arg_INTERFACE AND TARGET Benchmark_Examples)
                target_link_libraries(Benchmark_Examples PUBLIC ${arg_INTERFACE})
        endif ()
    endif ()


    cmake_path(ABSOLUTE_PATH arg_FOLDER OUTPUT_VARIABLE arg_FOLDER NORMALIZE)
    file (GLOB_RECURSE examples CONFIGURE_DEPENDS RELATIVE ${arg_FOLDER} "${arg_FOLDER}/*.cpp" )

    foreach (example IN LISTS examples)

        cmake_path(REMOVE_EXTENSION example OUTPUT_VARIABLE target_name)

        # Replace the slashes and dots with underscores to get a valid target name
        # (e.g. 'foo_bar_cpp' from 'foo/bar.cpp')
        string(REPLACE "/" "_" target_name ${target_name})

        add_executable(${target_name} ${arg_FOLDER}/${example})
        if(arg_INTERFACE)
            target_link_libraries(${target_name} PUBLIC ${arg_INTERFACE})
        endif ()
        set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${TCM_EXE_DIR}/examples")
        add_test(NAME ${target_name} COMMAND ${target_name})

        list(APPEND TARGETS ${target_name})

        if(NOT arg_WITH_BENCHMARK)
            tcm_log("Add ${target_name}")
            continue()
        endif ()

        file(READ "${arg_FOLDER}/${example}" file_content)

        string(REGEX MATCH " main[(][)]" can_benchmark "${file_content}")

        if(NOT can_benchmark)
            tcm_warn("Example \"${example}\" cannot be integrated in a benchmark.")
            tcm_warn("Reason:  only empty `main()`signature is supported (and with a return value).")
            continue()
        endif ()

        string(REGEX REPLACE " main[(]" " ${target_name}_main(" file_content "${file_content}")

        # TODO I could check if a replaced happened and if yes, then we could generate one
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
        set(benchmark_file ${CMAKE_CURRENT_BINARY_DIR}/benchmarks/${target_name}.cpp)
        file(WRITE ${benchmark_file} "${file_content}")
        target_sources(Benchmark_Examples PRIVATE ${benchmark_file})

        tcm_log("Add ${target_name} with benchmark added to Benchmark_Examples target.")
    endforeach ()
    set(TCM_EXAMPLE_TARGETS ${TARGETS} PARENT_SCOPE)
    tcm_section_end()
endfunction()


# ------------------------------------------------------------------------------
#   For internal usage.
#   Set some useful CMake variables.
#
macro(tcm__setup_examples)
endmacro()


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

    tcm__default_value(arg_HEADER_DIR "${CMAKE_CURRENT_BINARY_DIR}/ispc/")
    tcm__default_value(arg_HEADER_SUFFIX ".h")

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
function(tcm_target_setup_for_emscripten target)
    set(options)
    set(oneValueArgs
            SHELL_FILE  # Override default shell file.
            ASSETS_DIR  # Specify a directory if you want to copy it alongside output.
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm__default_value(arg_SHELL_FILE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html")

    if(NOT EMSCRIPTEN)
        return()
    endif ()

    set(CMAKE_EXECUTABLE_SUFFIX ".html" PARENT_SCOPE) # https://github.com/emscripten-core/emscripten/issues/18860
    target_link_options(${target} PRIVATE --shell-file ${arg_SHELL_FILE})
    target_link_options(${target} PRIVATE -sMAX_WEBGL_VERSION=2 -sALLOW_MEMORY_GROWTH=1 -sSTACK_SIZE=1mb)
    target_link_options(${target} PRIVATE -sEXPORTED_RUNTIME_METHODS=cwrap --no-heap-copy)
    target_link_options(${target} PRIVATE $<IF:$<CONFIG:DEBUG>,-sASSERTIONS=1,-sASSERTIONS=0> -sMALLOC=emmalloc)

    if(arg_ASSETS_DIR)
        target_link_options(${target} PRIVATE --preload-file ${arg_ASSETS_DIR}@$<TARGET_FILE_DIR:${target}>/assets)
        add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${target}>/assets
                COMMENT "Making directory $<TARGET_FILE_DIR:${target}>/assets/"
        )
        add_custom_command(TARGET ${target} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${arg_ASSETS_DIR}/assets $<TARGET_FILE_DIR:${target}>/assets
                COMMENT "Copying assets directory ${arg_ASSETS_DIR} to $<TARGET_FILE_DIR:${target}>/assets"
        )
    endif ()

endfunction()

#-------------------------------------------------------------------------------
#   For internal usage.
#   Embed and setup a default html shell file for emscripten.
#   TODO : Could it be done only when explicitly calling setup target ?
macro(tcm__setup_emscripten)
    file(WRITE "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html.in" [=[<!doctype html>
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
    configure_file("${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html.in" "${PROJECT_BINARY_DIR}/emscripten/shell_minimal.html" @ONLY)
endmacro()


# ------------------------------------------------------------------------------
# --- SETUP-DOCUMENTATION
# ------------------------------------------------------------------------------
# Description:
#   Setup documentation using doxygen and doxygen-awesome.
#   Use doxygen_add_docs() under the hood.
#   Any Doxygen config option can be override by setting relevant variables before calling `tcm_setup_docs()`.
#   For more information : https://cmake.org/cmake/help/latest/module/FindDoxygen.html
#
#   However, following parameters cannot not be overridden, since tcm_setup_docs() is setting them:
# * DOXYGEN_GENERATE_TREEVIEW YES
# * DOXYGEN_DISABLE_INDEX NO
# * DOXYGEN_FULL_SIDEBAR NO
# * DOXYGEN_HTML_COLORSTYLE	LIGHT # required with Doxygen >= 1.9.5
# * DOXYGEN_DOT_IMAGE_FORMAT svg
#
#   By default, DOXYGEN_USE_MDFILE_AS_MAINPAGE is set to "${PROJECT_SOURCE_DIR}/README.md".
#
#   Also, TCM provides a default header, footer, stylesheet, extra files (js script).
#   You can override them, but as they are tightly linked together, you are better off not calling tcm_setup_docs().
#
# Usage :
#   tcm_setup_docs()
#
function(tcm_setup_docs)
    set(options)
    set(oneValueArgs
            DOXYGEN_AWESOME_VERSION
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 TCM "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm_section("DOCS")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(TCM_DOXYGEN_AWESOME_VERSION      "v2.3.4")
    tcm__default_value(DOXYGEN_USE_MDFILE_AS_MAINPAGE   "${PROJECT_SOURCE_DIR}/README.md")
    tcm__default_value(DOXYGEN_OUTPUT_DIRECTORY         "${CMAKE_CURRENT_BINARY_DIR}/doxygen")

    if(NOT DEFINED DOXYGEN_HTML_HEADER)
        set(TMP_DOXYGEN_HTML_HEADER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html.temp")
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
        set(DOXYGEN_HTML_HEADER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html")
        configure_file(${TMP_DOXYGEN_HTML_HEADER} ${DOXYGEN_HTML_HEADER})
    endif ()

    if(NOT DEFINED DOXYGEN_HTML_FOOTER)
        set(TMP_DOXYGEN_HTML_FOOTER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html.temp")
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
        set(DOXYGEN_HTML_FOOTER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html")
        configure_file(${TMP_DOXYGEN_HTML_FOOTER} ${DOXYGEN_HTML_FOOTER})
    endif ()

    if(NOT DEFINED DOXYGEN_LAYOUT_FILE)
        set(DOXYGEN_LAYOUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/doxygen/layout.xml")
        file(WRITE ${DOXYGEN_LAYOUT_FILE} [=[<?xml version="1.0" encoding="UTF-8"?>
<doxygenlayout version="1.0">
  <!-- Generated by doxygen 1.9.8 -->
  <!-- Navigation index tabs for HTML output -->
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

    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    # Doxygen is a documentation generator and static analysis tool for software source trees.
    find_package(Doxygen REQUIRED dot QUIET)
    if(NOT Doxygen_FOUND)
        tcm_warn("Doxygen not found -> Skipping docs.")
        tcm_section_end()
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
        tcm_section_end()
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
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-darkmode-toggle.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-fragment-copy-button.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-paragraph-link.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-interactive-toc.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-tabs.js")

    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css")
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

    list(APPEND DOXYGEN_ALIASES [[html_frame{1}="@htmlonly<iframe src=\"\1\"></iframe>@endhtmlonly"]])
    list(APPEND DOXYGEN_ALIASES [[html_frame{3}="@htmlonly<iframe src=\"\1\" width=\"\2\" height=\"\3\"></iframe>@endhtmlonly"]])
    list(APPEND DOXYGEN_ALIASES [[widget{2}="@htmlonly<div class=\"\1\" id=\"\2\"></div>@endhtmlonly"]])
    list(APPEND DOXYGEN_ALIASES [[Doxygen="[Doxygen](https://www.doxygen.nl/index.html)"]])
    list(APPEND DOXYGEN_ALIASES [[Doxygen-awesome="[Doxygen Awesome CSS](https://jothepro.github.io/doxygen-awesome-css/)"]])

    # ------------------------------------------------------------------------------
    # --- CONFIGURATION
    # ------------------------------------------------------------------------------
    doxygen_add_docs(docs)

    # Utility target to open docs
    add_custom_target(open_docs COMMAND "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html")
    add_dependencies(open_docs docs)
    tcm_section_end()

endfunction()


# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------

macro(tcm_setup)
    if(NOT TARGET TCM)          # A target cannot be defined more than once.
        add_custom_target(TCM)  # Utility target to store some internal settings.
    endif ()

    # We keep going even if setup was already called in some top projects.
    # Some setup functions could behave differently if it is the main project or not.
    # As TCM requires CMake > 3.25, we are sure that PROJECT_IS_TOP_LEVEL is defined.
    # It was added in 3.21 : https://cmake.org/cmake/help/latest/variable/PROJECT_IS_TOP_LEVEL.html.
    # TODO: May not be a good idea. include_guard() or not ?

    tcm__setup_logging()
    tcm__setup_variables()
    tcm__setup_emscripten()
endmacro()

tcm_setup()

