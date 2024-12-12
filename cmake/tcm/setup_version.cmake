# ------------------------------------------------------------------------------
#           File : semantic_versioning.cmake
#           From : https://github.com/nunofachada/cmake-git-semver/blob/master/GetVersionFromGitTag.cmake
#    Description : Set project's version using semantic versioning, either from git in dev mode or from version file.
# ------------------------------------------------------------------------------
include_guard()
find_package(Git QUIET)

if (GIT_FOUND AND ${PROJECT_IS_TOP_LEVEL})
	# Get last tag from git
	execute_process(COMMAND ${GIT_EXECUTABLE} describe --abbrev=0 --tags
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			OUTPUT_VARIABLE ${PROJECT_NAME}_VERSION_STRING
			OUTPUT_STRIP_TRAILING_WHITESPACE
			ERROR_QUIET
	)

	if(${PROJECT_NAME}_VERSION_STRING)
		set(${PROJECT_NAME}_QUERY_NB_COMMITS "${${PROJECT_NAME}_VERSION_STRING}^..HEAD")
	else()
		set(${PROJECT_NAME}_VERSION_STRING "0.0.0")
		set(${PROJECT_NAME}_QUERY_NB_COMMITS "")
	endif()

	#How many commits since last tag
	execute_process(COMMAND ${GIT_EXECUTABLE} rev-list master ${${PROJECT_NAME}_QUERY_NB_COMMITS} --count
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			OUTPUT_VARIABLE ${PROJECT_NAME}_VERSION_AHEAD
			OUTPUT_STRIP_TRAILING_WHITESPACE
			ERROR_QUIET
	)

	# Get current commit SHA from git
	execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			OUTPUT_VARIABLE ${PROJECT_NAME}_VERSION_GIT_SHA
			OUTPUT_STRIP_TRAILING_WHITESPACE
			ERROR_QUIET
	)

	# Get partial versions into a list
	string(REGEX MATCHALL "-.*$|[0-9]+" ${PROJECT_NAME}_PARTIAL_VERSION_LIST ${${PROJECT_NAME}_VERSION_STRING})

	# Set the version numbers
	list(GET ${PROJECT_NAME}_PARTIAL_VERSION_LIST 0 ${PROJECT_NAME}_VERSION_MAJOR)
	list(GET ${PROJECT_NAME}_PARTIAL_VERSION_LIST 1 ${PROJECT_NAME}_VERSION_MINOR)
	list(GET ${PROJECT_NAME}_PARTIAL_VERSION_LIST 2 ${PROJECT_NAME}_VERSION_PATCH)

	# The tweak part is optional, so check if the list contains it
	list(LENGTH ${PROJECT_NAME}_PARTIAL_VERSION_LIST ${PROJECT_NAME}_PARTIAL_VERSION_LIST_LEN)
	if (${PROJECT_NAME}_PARTIAL_VERSION_LIST_LEN GREATER 3)
		list(GET ${PROJECT_NAME}_PARTIAL_VERSION_LIST 3 ${PROJECT_NAME}_VERSION_TWEAK)
		string(SUBSTRING ${${PROJECT_NAME}_VERSION_TWEAK} 1 -1 ${PROJECT_NAME}_VERSION_TWEAK)
	endif()

	# Unset the list
	unset(${PROJECT_NAME}_PARTIAL_VERSION_LIST)

	# Set full project version string
	set(${PROJECT_NAME}_VERSION_STRING_FULL
			${${PROJECT_NAME}_VERSION_STRING}+${${PROJECT_NAME}_VERSION_AHEAD}.${${PROJECT_NAME}_VERSION_GIT_SHA})

	# Save version to file (which will be used when Git is not available
	# or VERSION_UPDATE_FROM_GIT is disabled)
	file(WRITE ${CMAKE_SOURCE_DIR}/VERSION
			${${PROJECT_NAME}_VERSION_MAJOR}
			"." ${${PROJECT_NAME}_VERSION_MINOR}
			"." ${${PROJECT_NAME}_VERSION_PATCH}
	)
else()
	# Git not available, get version from file
	file(STRINGS VERSION ${PROJECT_NAME}_VERSION_LIST)
	string(REPLACE "." ${PROJECT_NAME}_VERSION_LIST ${${PROJECT_NAME}_VERSION_LIST})

	# Set partial versions
	list(GET ${PROJECT_NAME}_VERSION_LIST 0 ${PROJECT_NAME}_VERSION_MAJOR)
	list(GET ${PROJECT_NAME}_VERSION_LIST 1 ${PROJECT_NAME}_VERSION_MINOR)
	list(GET ${PROJECT_NAME}_VERSION_LIST 2 ${PROJECT_NAME}_VERSION_PATCH)
endif()

# Set project version (without the preceding 'v')
set(${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH})

message(STATUS "Version : ${${PROJECT_NAME}_VERSION_STRING}")
