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

