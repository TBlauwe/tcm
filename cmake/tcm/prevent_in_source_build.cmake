# ------------------------------------------------------------------------------
#           File : prevent_in_source_build.cmake
#           From : https://github.com/friendlyanon/cmake-init/
#    Description : Disallow in-source builds
# ------------------------------------------------------------------------------
include_guard()

# disallow in-source builds
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message("######################################################")
  message(FATAL_ERROR "Error: in-source builds are disabled")
  message("Please create a separate build directory and run cmake from there")
  message("######################################################")
endif()