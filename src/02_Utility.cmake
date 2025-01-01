# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   For internal usage.
#   Ensure arguments is set.
#   Should only be used inside a function.
#   Assume arguments are prefixed by arg_
#
macro(tcm__required arg_ARG arg_DESC)
    if(NOT DEFINED ${arg_${arg_ARG}})
        tcm_author_warn("Missing arguments ${arg_ARG}. ${arg_DESC}")
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   For internal usage.
#   Convenience macro to ensure target is set either as first argument or with `TARGET` keyword.
#
macro(tcm__ensure_target)
    if((NOT arg_TARGET) AND (NOT ARGV0))    # A target must be specified
        tcm_author_warn("Missing target. Needs to be either first argument or specified with keyword `TARGET`.")
    elseif(NOT arg_TARGET AND ARGV0)        # If not using TARGET, then put ARGV0 as target
        if(NOT TARGET ${ARGV0})             # Make sur that ARGV0 is a target
            tcm_author_warn("Missing target. Keyword TARGET is missing and first argument \"${ARGV0}\" is not a target.")
        endif()
        set(arg_TARGET ${ARGV0})
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   For internal usage.
#   Set a default _value to a _var if not defined.
#
macro(tcm__default_value arg_VAR arg_VALUE)
    if(NOT DEFINED ${arg_VAR})
        set(${arg_VAR} ${arg_VALUE})
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   Prevent warnings from displaying when building target
#   Useful when you do not want libraries warnings polluting your build output
#   TODO Seems to work in some cases but not all.
#   TODO Isn't it dangerous ? Should we not append rather than setting ?
#
function(tcm_target_suppress_warnings)
    set(one_value_args TARGET)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

    set_target_properties(${arg_TARGET} PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${arg_TARGET},INTERFACE_INCLUDE_DIRECTORIES>)
endfunction()


#-------------------------------------------------------------------------------
#   Define "-D${OPTION}" for TARGET for each option that is ON.
#
function(tcm_target_options)
    set(one_value_args TARGET)
    set(multi_value_args OPTIONS)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

    foreach (item IN LISTS arg_OPTIONS)
        if (${item})
            target_compile_definitions(${arg_TARGET} PUBLIC "${item}")
        endif ()
    endforeach ()
endfunction()


#-------------------------------------------------------------------------------
#   Post-build, copy files and folders to an asset/ folder inside target's output directory.
#
function(tcm_target_copy_assets)
    set(one_value_args
            TARGET
            OUTPUT_DIR
    )
    set(multi_value_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

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
                COMMAND ${CMAKE_COMMAND} -E make_directory "$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                COMMENT "Making directory $<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                VERBATIM
        )
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${files} "$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                COMMENT "Copying files [${files}] to $<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>."
                VERBATIM
        )
    endif ()

    if(folders)
        add_custom_command(
                TARGET ${arg_TARGET}
                POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different ${folders} "$<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>"
                COMMENT "Copying directories [${folders}] to $<IF:$<BOOL:${arg_OUTPUT_DIR}>,${arg_OUTPUT_DIR},$<TARGET_FILE_DIR:${arg_TARGET}>/assets>."
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
function(tcm_target_enable_optimisation_flags)
    set(one_value_args TARGET)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

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
function(tcm_target_enable_warning_flags)
    set(one_value_args TARGET)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")
    tcm__ensure_target()

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
    if(DEFINED ${PREVIOUS_CMAKE_MESSAGE_LOG_LEVEL})
        set(CMAKE_MESSAGE_LOG_LEVEL ${PREVIOUS_CMAKE_MESSAGE_LOG_LEVEL})
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   Check if <FILE> has changed and outputs result to <OUTPUT_VAR>
#
function(tcm_has_changed)
    set(one_value_args FILE OUTPUT_VAR)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")

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
