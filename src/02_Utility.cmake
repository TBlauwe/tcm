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
#   TODO Also look at embedding ?
#   TODO No need to specify dir, copy at at $<TARGET:FILE_DIR>
#   Copy FOLDER alongside target file
#
function(tcm_target_assets arg_TARGET)
    set(one_value_args SOURCE DESTINATION)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "${one_value_args}" "")
    add_custom_target(${arg_TARGET}_copy_assets
            COMMAND ${CMAKE_COMMAND} -E copy_directory "${arg_SOURCE}" "${arg_DESTINATION}"
            COMMENT "(${arg_TARGET}) - Copying assets from directory \"${arg_SOURCE}\" to \"${arg_DESTINATION}\""
    )
    add_dependencies(${arg_TARGET} ${arg_TARGET}_copy_assets)
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
