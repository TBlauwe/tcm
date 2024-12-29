# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------
# Each `tcm__module` setup and configure cmake to enable modules' functionalities.
set(TCM_VERSION @PROJECT_VERSION@)
tcm__module_logging()
tcm__setup_variables()

tcm_check_start("Setup TCM")
    tcm_info("Version: ${TCM_VERSION}")

    tcm__default_value(TCM_TOOLS "CPM;CCACHE")

    if(CPM IN_LIST TCM_TOOLS)
        tcm__setup_cpm()
    endif ()

    if(CCACHE IN_LIST TCM_TOOLS)
        tcm__setup_cache()
    endif ()

    tcm__module_emscripten()
tcm_check_pass("done.")
