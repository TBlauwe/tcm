# ------------------------------------------------------------------------------
#           File : warning_guard.cmake
#           From : https://github.com/friendlyanon/cmake-init-shared-static/blob/master/cmake/variables.cmake
#    Description : Set variable ${PROJECT_NAME}_WARNING_GUARD to prevent warnings from your library when consumed.
#           Usage: target_include_directories(your_library ${${PROJECT_NAME}_WARNING_GUARD} PUBLIC your_include_dir/)
# ------------------------------------------------------------------------------
include_guard()

# ---- Warning guard ----
# target_include_directories with the SYSTEM modifier will request the compiler
# to omit warnings from the provided paths, if the compiler supports that.
# This is to provide a user experience similar to find_package when
# add_subdirectory or FetchContent is used to consume this project
set(${PROJECT_NAME}_WARNING_GUARD "")
if(NOT PROJECT_IS_TOP_LEVEL)
  option(${PROJECT_NAME}_INCLUDES_WITH_SYSTEM "Use SYSTEM modifier for shared's includes, disabling warnings" ON)
  mark_as_advanced(${PROJECT_NAME}_INCLUDES_WITH_SYSTEM)
  if(${PROJECT_NAME}_INCLUDES_WITH_SYSTEM)
    set(${PROJECT_NAME}_WARNING_GUARD SYSTEM)
  endif()
endif()
