# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------
# Each `tcm__module` setup and configure cmake to enable modules' functionalities.
set(TCM_VERSION @PROJECT_VERSION@)
tcm_info("TCM Version: ${TCM_VERSION}")

tcm__module_logging()
tcm__setup_variables()
tcm__module_emscripten()
