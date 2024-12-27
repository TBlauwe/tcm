# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#   For internal usage.
#   Set some useful CMake variables.
#
macro(tcm__setup_variables)
    tcm__default_value(TCM_EXE_DIR "${PROJECT_BINARY_DIR}/bin")

    #-------------------------------------------------------------------------------
    # Set host machine
    #
    set (TCM_HOST_WINDOWS 0)
    set (TCM_HOST_OSX 0)
    set (TCM_HOST_LINUX 0)
    if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
        set(TCM_HOST_WINDOWS 1)
        tcm_debug("Host system : Windows")
    elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
        set(TCM_HOST_OSX 1)
        tcm_debug("Host system : OSX")
    elseif (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Linux")
        set(TCM_HOST_LINUX 1)
        tcm_debug("Host system : Linux")
    else()
        set(TCM_HOST_LINUX 1)
        tcm_debug("Host system not recognized, setting to 'Linux'")
    endif()

    #-------------------------------------------------------------------------------
    # Set Compiler
    #
    tcm_debug("Compiler : ${CMAKE_CXX_COMPILER_ID}")
    if (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
        set(TCM_CLANG 1)
        if (${CMAKE_CXX_COMPILER_ID} MATCHES "AppleClang")
            set(TCM_APPLE_CLANG 1)
        endif()
        if (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC") # using clang with clang-cl front end
            set(TCM_CLANG_CL 1)
        endif()
    elseif (${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
        set(TCM_GCC 1)
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
        set(TCM_INTEL 1)
    elseif (MSVC)
        set(TCM_MSVC 1)
    else()
        if (EMSCRIPTEN)
            set(TCM_EMSCRIPTEN 1)
            set(TCM_CLANG 1)
            #elseif (TCM_ANDROID)
            #    set(TCM_CLANG 1)
        endif()
    endif()

    #-------------------------------------------------------------------------------
    #   Computed Gotos
    #
    try_compile(TCM_SUPPORT_COMPUTED_GOTOS SOURCE_FROM_CONTENT computed_goto_test.c "int main() { static void* labels[] = {&&label1, &&label2}; int i = 0; goto *labels[i]; label1: return 0; label2: return 1; } ")
    tcm_debug("Feature support - computed gotos : ${TCM_SUPPORT_COMPUTED_GOTOS}")

    #-------------------------------------------------------------------------------
    #   Warning Guard
    #
    # target_include_directories with the SYSTEM modifier will request the compiler
    # to omit warnings from the provided paths, if the compiler supports that.
    # This is to provide a user experience similar to find_package when
    # add_subdirectory or FetchContent is used to consume this project
    #
    if(PROJECT_IS_TOP_LEVEL)
        set(TCM_WARNING_GUARD "")
    else()
        option(TCM_INCLUDES_WITH_SYSTEM "Use SYSTEM modifier for shared includes, disabling warnings" ON)
        mark_as_advanced(TCM_INCLUDES_WITH_SYSTEM)
        if(TCM_INCLUDES_WITH_SYSTEM)
            set(TCM_WARNING_GUARD SYSTEM)
        endif()
    endif ()
endmacro()
