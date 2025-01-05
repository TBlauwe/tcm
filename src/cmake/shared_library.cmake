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

