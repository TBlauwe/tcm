# ------------------------------------------------------------------------------
# --- TOOLS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.
#
macro(tcm__setup_cpm)
    tcm__default_value(CPM_INDENT "(CPM)")
    tcm__default_value(CPM_USE_NAMED_CACHE_DIRECTORIES ON)  # See https://github.com/cpm-cmake/CPM.cmake?tab=readme-ov-file#cpm_use_named_cache_directories
    tcm__default_value(CPM_DOWNLOAD_VERSION 0.40.2)

    if(CPM_SOURCE_CACHE)
        set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
    elseif(DEFINED ENV{CPM_SOURCE_CACHE})
        set(CPM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
    else()
        set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
    endif()

    # Expand relative path. This is important if the provided path contains a tilde (~)
    file(REAL_PATH ${CPM_DOWNLOAD_LOCATION} CPM_DOWNLOAD_LOCATION)

    if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
        tcm_info("Downloading CPM.cmake to ${CPM_DOWNLOAD_LOCATION}")
        file(DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake ${CPM_DOWNLOAD_LOCATION})
    else()
        # resume download if it previously failed
        file(READ ${CPM_DOWNLOAD_LOCATION} check)
        if("${check}" STREQUAL "")
            tcm_info("Downloading CPM.cmake to ${CPM_DOWNLOAD_LOCATION}")
            file(DOWNLOAD https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake ${CPM_DOWNLOAD_LOCATION})
        endif()
    endif()

    include(${CPM_DOWNLOAD_LOCATION})
    tcm_info("CPM: ${CPM_DOWNLOAD_LOCATION}")
endmacro()

# ------------------------------------------------------------------------------
# Description:
#   Setup cache (only if top level project), like ccache (https://ccache.dev/) if available on system.
#
# Usage :
#   tcm_setup_cache()
#
function(tcm__setup_cache)
    if(EMSCRIPTEN) # Doesn't seems to work with emscripten (https://github.com/emscripten-core/emscripten/issues/11974)
        return()
    endif()

    set(CACHE_OPTION "ccache" CACHE STRING "Compiler cache to be used")
    set(CACHE_OPTION_VALUES "ccache" "sccache")
    set_property(CACHE CACHE_OPTION PROPERTY STRINGS ${CACHE_OPTION_VALUES})

    if(NOT ${CACHE_OPTIONS} IN_LIST CACHE_OPTION_VALUES)
        tcm_warn("Using custom compiler cache system: '${CACHE_OPTION}'. Supported entries are ${CACHE_OPTION_VALUES}")
    endif()

    find_program(CACHE_BINARY NAMES ${CACHE_OPTION_VALUES})
    if(CACHE_BINARY)
        tcm_info("Cache System: ${CACHE_BINARY}.")
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_C_COMPILER_LAUNCHER ${CACHE_BINARY} PARENT_SCOPE)
        set(CMAKE_CUDA_COMPILER_LAUNCHER "${CACHE_BINARY}" PARENT_SCOPE)
    else()
        tcm_warn("${CACHE_OPTION} is enabled but was not found. Not using it")
    endif()
endfunction()