# ------------------------------------------------------------------------------
# File:
#   get_tcm.cmake
#
# Author:
#   TBlauwe
#
# Description:
#   Script to download tcm
#
# Usage:
#   include(cmake/tcm.cmake) # tcm_setup() is called automatically.
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.21) # TODO Check for minimum required version.

if(NOT DEFINED TCM_DOWNLOAD_VERSION)
    set(TCM_DOWNLOAD_VERSION 0.1.0)
endif()

if(TCM_SOURCE_CACHE)
    set(TCM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/TCM_${TCM_DOWNLOAD_VERSION}.cmake")
elseif(DEFINED ENV{CPM_SOURCE_CACHE})
    set(TCM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/TCM_${TCM_DOWNLOAD_VERSION}.cmake")
else()
    set(TCM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/TCM_${TCM_DOWNLOAD_VERSION}.cmake")
endif()

# Expand relative path. This is important if the provided path contains a tilde (~)
get_filename_component(TCM_DOWNLOAD_LOCATION ${TCM_DOWNLOAD_LOCATION} ABSOLUTE)

function(download_tcm)
    tcm_info("Downloading TCM.cmake to ${TCM_DOWNLOAD_LOCATION}")
    file(DOWNLOAD https://raw.githubusercontent.com/TBlauwe/tcm/refs/heads/master/cmake/tcm.cmake
            ${TCM_DOWNLOAD_LOCATION}
    )
endfunction()

if(NOT (EXISTS ${TCM_DOWNLOAD_LOCATION}))
    download_tpm()
else()
    # resume download if it previously failed
    file(READ ${TCM_DOWNLOAD_LOCATION} check)
    if("${check}" STREQUAL "")
        download_tpm()
    endif()
endif()

include(${TCM_DOWNLOAD_LOCATION})