# ------------------------------------------------------------------------------
# --- SETUP CPM
# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.
#
macro(tcm_setup_cpm)
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
    tcm_info("Using CPM : ${CPM_DOWNLOAD_LOCATION}")
endmacro()