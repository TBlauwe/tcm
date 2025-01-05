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
cmake_minimum_required(VERSION 3.26)

if(NOT EXISTS ${TCM_FILE}) # TCM cache this variable when included.
    if(NOT DEFINED TCM_DOWNLOAD_VERSION)
        set(TCM_DOWNLOAD_VERSION 1.0.0)
    endif()

    if(CPM_SOURCE_CACHE)
        set(TCM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/tcm/TCM_${TCM_DOWNLOAD_VERSION}.cmake")
    elseif(DEFINED ENV{CPM_SOURCE_CACHE})
        set(TCM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/tcm/TCM_${TCM_DOWNLOAD_VERSION}.cmake")
    else()
        set(TCM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/TCM_${TCM_DOWNLOAD_VERSION}.cmake")
    endif()

    # Expand relative path. This is important if the provided path contains a tilde (~)
    get_filename_component(TCM_DOWNLOAD_LOCATION ${TCM_DOWNLOAD_LOCATION} ABSOLUTE)

    if(NOT (EXISTS ${TCM_DOWNLOAD_LOCATION}))
        message(CHECK_START "Downloading TCM.cmake to ${TCM_DOWNLOAD_LOCATION}")
        if("${TCM_DOWNLOAD_VERSION}" MATCHES "master")
            file(DOWNLOAD https://raw.githubusercontent.com/TBlauwe/tcm/master/cmake/tcm.cmake
                    ${TCM_DOWNLOAD_LOCATION}
                    STATUS DOWNLOAD_STATUS
            )
        else()
            file(DOWNLOAD https://github.com/TBlauwe/tcm/releases/download/v${TCM_DOWNLOAD_VERSION}/tcm.cmake
                    ${TCM_DOWNLOAD_LOCATION}
                    STATUS DOWNLOAD_STATUS
            )
        endif ()
        list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
        list(GET DOWNLOAD_STATUS 1 ERROR_MESSAGE)
        if(${STATUS_CODE} EQUAL 0) # Check if download was successful.
            message(CHECK_PASS "done.")
        else()
            # Exit CMake if the download failed, printing the error message.
            message(CHECK_FAIL "error ${STATUS_CODE} occurred during download: ${ERROR_MESSAGE}")
            file(REMOVE ${TCM_DOWNLOAD_LOCATION}) # Prevent empty file if download failed.
        endif()
    endif()

    include(${TCM_DOWNLOAD_LOCATION})
else ()
    include(${TCM_FILE})
endif ()
