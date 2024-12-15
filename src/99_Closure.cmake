macro(tcm_setup)
    tcm__setup_logging()
    tcm__setup_variables()
endmacro()

# Automatically setup tcm on include
tcm_setup()
