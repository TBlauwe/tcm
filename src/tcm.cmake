# ------------------------------------------------------------------------------
# File:
#   tcm.cmake
#
# Author:
#   TBlauwe
#
# Description:
#   Opinionated CMake module to share and manage common functionality and settings for C++ / C project.
#   Functions and macros are all prefixed with tcm_.
#   Private functions and macros are all prefixed with tcm__ (double underscore).
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.25) # Required for `SOURCE_FROM_CONTENT` : https://cmake.org/cmake/help/latest/command/try_compile.html

# ------------------------------------------------------------------------------
# --- OPTIONS
# ------------------------------------------------------------------------------
@TCM_OPTIONS_MIXIN@

# ------------------------------------------------------------------------------
# --- LOGGING
# ------------------------------------------------------------------------------
# This section contains some utility functions for logging purposes
# They are simple wrappers over `message()`, whom are mostly noop when current project is not top level.
@TCM_LOGGING_MIXIN@

# ------------------------------------------------------------------------------
# --- UTILITY
# ------------------------------------------------------------------------------
@TCM_UTILITY_MIXIN@

# ------------------------------------------------------------------------------
# --- VARIABLES
# ------------------------------------------------------------------------------
@TCM_VARIABLES_MIXIN@

# ------------------------------------------------------------------------------
# --- CODE-BLOCKS
# ------------------------------------------------------------------------------
# Description:
#   Generate markdown code blocks from a source.
#   Included source file path must be relative to project source directory.
#   File's extension is used to determine the code block language.
#   If included files have not changed, then files will be left untouched.
#
# Usage :
#   // In some file, like README.md
#   <!--BEGIN_INCLUDE="relative_path/to/file.cpp"-->
#   Everything between this two tags will be replaced by the content of the file inside a code block.
#   <!--END_INCLUDE-->
#
#   // In some cmake file, like root CMakeLists.txt
#   tcm_code_blocks(README.md)
@TCM_CODE_BLOCKS_MIXIN@

# ------------------------------------------------------------------------------
# --- SETUP CPM
# ------------------------------------------------------------------------------
# See: https://github.com/cpm-cmake/CPM.cmake
# Download and install CPM if not already present.
@TCM_CPM_MIXIN@

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
@TCM_SETUP_PROJECT_VERSION_MIXIN@


# ------------------------------------------------------------------------------
# --- SETUP-CACHE
# ------------------------------------------------------------------------------
# Description:
#   Setup cache (only if top level project), like ccache (https://ccache.dev/) if available on system.

# Usage :
#   tcm_setup_cache()
@TCM_SETUP_CACHE_MIXIN@

# ------------------------------------------------------------------------------
# --- SETUP-DOCUMENTATION
# ------------------------------------------------------------------------------
# Description:
#   Setup documentation using doxygen and doxygen-awesome.
#   Use doxygen_add_docs() under the hood.
#   Any Doxygen config option can be override by setting relevant variables before calling `tcm_setup_docs()`.
#   For more information : https://cmake.org/cmake/help/latest/module/FindDoxygen.html
#
#   However, following parameters cannot not be overridden, since tcm_setup_docs() is setting them:
# * DOXYGEN_GENERATE_TREEVIEW YES
# * DOXYGEN_DISABLE_INDEX NO
# * DOXYGEN_FULL_SIDEBAR NO
# * DOXYGEN_HTML_COLORSTYLE	LIGHT # required with Doxygen >= 1.9.5
# * DOXYGEN_DOT_IMAGE_FORMAT svg
#
#   By default, DOXYGEN_USE_MDFILE_AS_MAINPAGE is set to "${PROJECT_SOURCE_DIR}/README.md".
#
#   Also, TCM provides a default header, footer, stylesheet, extra files (js script).
#   You can override them, but as they are tightly linked together, you are better off not calling tcm_setup_docs().
#
# Usage :
#   tcm_setup_docs()
@TCM_SETUP_DOCS_MIXIN@

# ------------------------------------------------------------------------------
# --- CLOSURE
# ------------------------------------------------------------------------------
@TCM_CLOSURE_MIXIN@
