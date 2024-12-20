# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------

macro(tcm_setup)
    tcm__setup_logging()
    tcm__setup_variables()
    tcm__setup_emscripten()
endmacro()

# Automatically setup tcm on include
tcm_setup()
