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
#   include(cmake/get_tcm.cmake)
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.25) # TCM minimum required version is 3.25.

function(download_tcm)
    message(STATUS "Downloading TCM.cmake to ${TCM_DOWNLOAD_LOCATION}")
    file(DOWNLOAD https://github.com/TBlauwe/tcm/releases/download/${TCM_DOWNLOAD_VERSION}/tcm.cmake ${TCM_DOWNLOAD_LOCATION})
endfunction()

if(NOT DEFINED TCM_DOWNLOAD_VERSION)
    set(TCM_DOWNLOAD_VERSION 0.4.0)
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

if(NOT (EXISTS ${TCM_DOWNLOAD_LOCATION}))
    download_tcm()
else()
    # resume download if it previously failed
    file(READ ${TCM_DOWNLOAD_LOCATION} check)
    if("${check}" STREQUAL "")
        download_tcm()
    endif()
endif()

include(${TCM_DOWNLOAD_LOCATION})
