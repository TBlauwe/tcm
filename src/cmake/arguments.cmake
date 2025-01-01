# ------------------------------------------------------------------------------
# --- MODULE: Arguments
#
#   This module defines functions to improve UX by checking appropriate API usage.
# ------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#   FOR INTERNAL USAGE: Make some assumptions (use `arg_TARGET`)
#   Ensure target is set either as first argument or with `TARGET` keyword.
#
macro(tcm__ensure_target)
endmacro()


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
