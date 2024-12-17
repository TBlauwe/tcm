# ------------------------------------------------------------------------------
# --- SETUP PROJECT VERSION
# ------------------------------------------------------------------------------
# Description:
#   Set project's version using semantic versioning, either from git in dev mode or from version file.
#   Expected to be called from root CMakeLists.txt and from a valid git directory.

# Credits:
#   Adapted from https://github.com/nunofachada/cmake-git-semver/blob/master/GetVersionFromGitTag.cmake
#
# Usage :
#   tcm_setup_project_version()
#
function(tcm_setup_project_version)
    find_package(Git QUIET)
    if (GIT_FOUND AND ${PROJECT_IS_TOP_LEVEL})
        # Get last tag from git
        execute_process(COMMAND ${GIT_EXECUTABLE} describe --abbrev=0 --tags
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE VERSION_STRING
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
        )

        string(REGEX MATCH "v?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?" VERSION_STRING ${VERSION_STRING})
        if(NOT VERSION_STRING)
            set(${PROJECT_NAME}_VERSION_MAJOR "0" PARENT_SCOPE)
            set(PROJECT_VERSION_MAJOR "0" PARENT_SCOPE)
            set(${PROJECT_NAME}_VERSION_MINOR "0" PARENT_SCOPE)
            set(PROJECT_VERSION_MINOR "0" PARENT_SCOPE)
            set(${PROJECT_NAME}_VERSION_PATCH "0" PARENT_SCOPE)
            set(PROJECT_VERSION_PATCH "0" PARENT_SCOPE)
        else()
            string(REPLACE "." ";" PARTIAL_VERSION_LIST ${VERSION_STRING})
            list(LENGTH PARTIAL_VERSION_LIST LIST_LENGTH)

            # Set Major
            list(GET PARTIAL_VERSION_LIST 0 VALUE)
            set(${PROJECT_NAME}_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
            set(PROJECT_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
            set(VERSION ${VALUE})

            #Set Minor
            if(LIST_LENGTH GREATER_EQUAL 2)
                list(GET PARTIAL_VERSION_LIST 1 VALUE)
                set(${PROJECT_NAME}_VERSION_MINOR ${VALUE} PARENT_SCOPE)
                set(PROJECT_VERSION_MINOR ${VALUE} PARENT_SCOPE)
                string(APPEND VERSION ".${VALUE}")
            else ()
                set(${PROJECT_NAME}_VERSION_MINOR 0 PARENT_SCOPE)
                set(PROJECT_VERSION_MINOR 0 PARENT_SCOPE)
                string(APPEND VERSION ".0")
            endif ()

            #Set Patch
            if(LIST_LENGTH GREATER_EQUAL 3)
                list(GET PARTIAL_VERSION_LIST 2 VALUE)
                set(${PROJECT_NAME}_VERSION_PATCH ${VALUE} PARENT_SCOPE)
                set(PROJECT_VERSION_PATCH ${VALUE} PARENT_SCOPE)
                string(APPEND VERSION ".${VALUE}")
            else ()
                set(${PROJECT_NAME}_VERSION_PATCH 0 PARENT_SCOPE)
                set(PROJECT_VERSION_PATCH 0 PARENT_SCOPE)
                string(APPEND VERSION ".0")
            endif ()
        endif()

        set(${PROJECT_NAME}_VERSION ${VERSION} PARENT_SCOPE)
        set(PROJECT_VERSION ${VERSION} PARENT_SCOPE)

        # Save version to file
        file(WRITE ${CMAKE_SOURCE_DIR}/VERSION ${VERSION})

    else()
        # Git not available, get version from file
        file(STRINGS "VERSION" VERSION)
        set(${PROJECT_NAME}_VERSION ${VERSION} PARENT_SCOPE)
        set(PROJECT_VERSION ${VERSION} PARENT_SCOPE)

        string(REPLACE "." ";" VERSION_LIST ${VERSION})
        list(GET VERSION_LIST 0 VALUE)
        set(${PROJECT_NAME}_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
        set(PROJECT_VERSION_MAJOR ${VALUE} PARENT_SCOPE)
        list(GET VERSION_LIST 1 VALUE)
        set(${PROJECT_NAME}_VERSION_MINOR ${VALUE} PARENT_SCOPE)
        set(PROJECT_VERSION_MINOR ${VALUE} PARENT_SCOPE)
        list(GET VERSION_LIST 2 VALUE)
        set(${PROJECT_NAME}_VERSION_PATCH ${VALUE} PARENT_SCOPE)
        set(PROJECT_VERSION_PATCH ${VALUE} PARENT_SCOPE)
    endif()

    tcm_log("Project Version : ${VERSION}")
endfunction()