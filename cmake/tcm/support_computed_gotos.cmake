# ------------------------------------------------------------------------------
#           File : support_computed_gotos.cmake
#         Author : TBlauwe
#    Description : CMake function to include a file inside a code block.
# Computed gotos are supported by Clang and GCC, but not MSVC
#                  File's extension is used to determine the code block language.
#          Usage :
#                  <!--BEGIN_INCLUDE="path/to/file.cpp"-->
#                  Everything between this two tags will be replaced by the content of the file inside a code block.
#                  <!--END_INCLUDE-->
# ------------------------------------------------------------------------------
include_guard()

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")                      # using Clang
    #if (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")    # using clang with clang-cl front end
    #elseif (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU") # using clang with regular front end
    #endif()
    set(${PROJECT_NAME}_SUPPORT_COMPUTED_GOTOS TRUE)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")                    # using GCC
    set(${PROJECT_NAME}_SUPPORT_COMPUTED_GOTOS TRUE)
#elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")                 # using Intel C++
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")                   # using Visual Studio C++
    set(${PROJECT_NAME}_SUPPORT_COMPUTED_GOTOS FALSE)
endif()