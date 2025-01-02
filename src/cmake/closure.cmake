# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------
tcm__module_logging()

set_property(GLOBAL PROPERTY TCM_INITIALIZED true)
set(TCM_FILE "${CMAKE_CURRENT_LIST_FILE}" CACHE INTERNAL "")
if(NOT DEFINED TCM_VERSION)
    set(TCM_VERSION @PROJECT_VERSION@ CACHE INTERNAL "")
    tcm_info("TCM Version: ${TCM_VERSION}")
endif ()

tcm__module_variables()
tcm__module_tools()

