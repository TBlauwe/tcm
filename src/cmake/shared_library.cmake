# ------------------------------------------------------------------------------
# --- SHARED
# ------------------------------------------------------------------------------
include(GenerateExportHeader)

#-------------------------------------------------------------------------------
#   Generate export header for a target.
#   Export header directory will be included in a private scope.
#
function(tcm_target_export_header arg_TARGET)
    set(one_value_args
            EXPORT_FILE_NAME
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "" "${one_value_args}" "" "")
    tcm_default_value(arg_EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/export/${arg_TARGET}/export.h")

    generate_export_header(
            ${arg_TARGET}
            EXPORT_FILE_NAME ${arg_EXPORT_FILE_NAME}
    )

    string(TOUPPER ${arg_TARGET} UPPER_NAME)
    if(NOT BUILD_SHARED_LIBS)
        target_compile_definitions(${arg_TARGET} PUBLIC ${UPPER_NAME}_STATIC_DEFINE)
    endif()

    set_target_properties(${arg_TARGET} PROPERTIES
            CXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN YES
            VERSION "${PROJECT_VERSION}"
            SOVERSION "${PROJECT_VERSION_MAJOR}"
            EXPORT_NAME ${arg_TARGET}
            OUTPUT_NAME ${arg_TARGET}
    )

    target_include_directories(${arg_TARGET} SYSTEM PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/export>)
endfunction()

