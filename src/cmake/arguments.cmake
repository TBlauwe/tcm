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
#   FOR INTERNAL USAGE : it makes assumptions about calling code.
#
#   Ensure proper usage of function API.
#   If not, then it stop cmake execution and print correct usage.
#
macro(tcm_function_parse_arguments)
    if(NOT DEFINED prefix)
        set(prefix arg)
    endif ()
    cmake_parse_arguments(PARSE_ARGV 0 ${prefix} "${options}" "${one_value_args}" "${multi_value_args}")

    foreach (argument IN LISTS options)
        tcm__check_var(${prefix} ${argument} "${required_args}" "")
    endforeach ()
    foreach (argument IN LISTS one_value_args)
        tcm__check_var(${prefix} ${argument} "${required_args}" "<item>")
    endforeach ()
    foreach (argument IN LISTS multi_value_args)
        tcm__check_var(${prefix} ${argument} "${required_args}" "<item> ...")
    endforeach ()

    if(DEFINED TCM_API_MISUSE)
        message(FATAL_ERROR "Improper API usage: "
                "${CMAKE_CURRENT_FUNCTION}("
                ${usage_message}
                "\n)"
        )
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   Set VAR to VALUE if not already defined.
#
macro(tcm_default_value arg_VAR arg_VALUE)
    if(NOT DEFINED ${arg_VAR})
        set(${arg_VAR} ${arg_VALUE})
    endif ()
endmacro()


#-------------------------------------------------------------------------------
#   FOR INTERNAL USAGE: Make some assumptions (use `arg_TARGET`)
#   Ensure target is set either as first argument or with `TARGET` keyword.
#
macro(tcm__ensure_target)
    if((NOT arg_TARGET) AND (NOT ARGV0))    # A target must be specified
        message(FATAL_ERROR "Missing required target. A target must be provided either as first argument or with keyword `TARGET`.")
    elseif(NOT arg_TARGET AND ARGV0)        # If not using TARGET, then put ARGV0 as target
        if(NOT TARGET ${ARGV0})             # Make sur that ARGV0 is a target
            message(FATAL_ERROR "First argument `${ARGV0}` is not a target. A target must be provided either as first argument or with keyword `TARGET`.")
        endif()
        set(arg_TARGET ${ARGV0})
    endif ()
endmacro()

