get_property(TCM_INITIALIZED GLOBAL PROPERTY TCM_INITIALIZED SET)

#If tcm is already initialized, just update logging module to set message context
if(TCM_INITIALIZED)
    tcm__module_logging()
    return()
endif ()
