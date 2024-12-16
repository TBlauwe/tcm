#-------------------------------------------------------------------------------
#   Prevent warnings from displaying when building target
#   Useful when you do not want libraries warnings polluting your build output
#   TODO Seems to work in some cases but not all.
#
function(tcm_suppress_warnings _target)
    set_target_properties(${_target} PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${_target},INTERFACE_INCLUDE_DIRECTORIES>)
endfunction()


#-------------------------------------------------------------------------------
#   Define "-D${_option}" for _target when _option is ON.
#
function(tcm_option_define _target _option)
    if (${_option})
        target_compile_definitions(${_target} PUBLIC "${_option}")
    endif ()
endfunction()

#-------------------------------------------------------------------------------
#   TODO Also look at embedding ?
#   Copy folder _src_dir to _dst_dir before _target is built.
#
function(tcm_target_assets _target _src_dir _dst_dir)
    add_custom_target(${_target}_copy_assets
            COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${_src_dir} ${_dst_dir}
            COMMENT "(${_target}) - Copying assets from directory ${_src_dir} to ${_dst_dir}"
    )
    add_dependencies(${_target} ${_target}_copy_assets)
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
#   Enable optimisation flags on release builds for _target
#
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


#-------------------------------------------------------------------------------
#   Enable warnings flags for _target
#
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

#-------------------------------------------------------------------------------
#   Set a default _value to a _var if not defined.
#
macro(tcm__default_value _var _value)
    if(NOT DEFINED ${_var})
        set(${_var} ${_value})
    endif ()
endmacro()
