function(tcm_setup_cache)
    if(EMSCRIPTEN) # Doesn't seems to work with emscripten (https://github.com/emscripten-core/emscripten/issues/11974)
        return()
    endif()

    set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
    set(CACHE_OPTION_VALUES "ccache" "sccache")
    set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})
    list(
            FIND
            CACHE_OPTION_VALUES
            ${CACHE_OPTION}
            CACHE_OPTION_INDEX
    )

    if(${CACHE_OPTION_INDEX} EQUAL -1)
        tcm_log("Using custom compiler cache system: '${CACHE_OPTION}'. Supported entries are ${CACHE_OPTION_VALUES}")
    endif()

    find_program(CACHE_BINARY NAMES ${CACHE_OPTION_VALUES})
    if(CACHE_BINARY)
        tcm_log("Using Cache System : ${CACHE_BINARY}.")
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_C_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_CUDA_COMPILER_LAUNCHER "${CACHE_BINARY}" PARENT_SCOPE)
    else()
        tcm_warn("${CACHE_OPTION} is enabled but was not found. Not using it")
    endif()
endfunction()
