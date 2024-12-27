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
#
function(tcm_setup_docs)
    set(options)
    set(oneValueArgs
            DOXYGEN_AWESOME_VERSION
    )
    set(multiValueArgs)
    cmake_parse_arguments(PARSE_ARGV 0 TCM "${options}" "${oneValueArgs}" "${multiValueArgs}")

    tcm_section("DOCS")

    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(TCM_DOXYGEN_AWESOME_VERSION      "v2.3.4")
    tcm__default_value(DOXYGEN_USE_MDFILE_AS_MAINPAGE   "${PROJECT_SOURCE_DIR}/README.md")
    tcm__default_value(DOXYGEN_OUTPUT_DIRECTORY         "${CMAKE_CURRENT_BINARY_DIR}/doxygen")

    if(NOT DEFINED DOXYGEN_HTML_HEADER)
        set(TMP_DOXYGEN_HTML_HEADER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html.temp")
        file(WRITE ${TMP_DOXYGEN_HTML_HEADER} [=[@TCM_DOXYGEN_HTML_HEADER_DEFAULT@]=])
        set(DOXYGEN_HTML_HEADER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html")
        configure_file(${TMP_DOXYGEN_HTML_HEADER} ${DOXYGEN_HTML_HEADER})
    endif ()

    if(NOT DEFINED DOXYGEN_HTML_FOOTER)
        set(TMP_DOXYGEN_HTML_FOOTER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html.temp")
        file(WRITE ${TMP_DOXYGEN_HTML_FOOTER} [=[@TCM_DOXYGEN_HTML_FOOTER_DEFAULT@]=])
        set(DOXYGEN_HTML_FOOTER "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html")
        configure_file(${TMP_DOXYGEN_HTML_FOOTER} ${DOXYGEN_HTML_FOOTER})
    endif ()

    if(NOT DEFINED DOXYGEN_LAYOUT_FILE)
        set(DOXYGEN_LAYOUT_FILE "${CMAKE_CURRENT_BINARY_DIR}/doxygen/layout.xml")
        file(WRITE ${DOXYGEN_LAYOUT_FILE} [=[@TCM_DOXYGEN_LAYOUT_FILE_DEFAULT@]=])
    endif ()

    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    # Doxygen is a documentation generator and static analysis tool for software source trees.
    find_package(Doxygen REQUIRED dot QUIET)
    if(NOT Doxygen_FOUND)
        tcm_warn("Doxygen not found -> Skipping docs.")
        tcm_section_end()
        return()
    endif()

    # Doxygen awesome CSS is a custom CSS theme for doxygen html-documentation with lots of customization parameters.
    CPMAddPackage(
            NAME DOXYGEN_AWESOME_CSS
            GIT_TAG ${TCM_DOXYGEN_AWESOME_VERSION}
            GITHUB_REPOSITORY jothepro/doxygen-awesome-css
    )
    if(NOT DOXYGEN_AWESOME_CSS_ADDED)
        tcm_warn("Could not add DOXYGEN_AWESOME_CSS -> Skipping docs.")
        tcm_section_end()
        return()
    endif()


    # ------------------------------------------------------------------------------
    # --- Mandatory Doxyfile.in settings
    # ------------------------------------------------------------------------------
    # --- Required by doxygen-awesome-css
    set(DOXYGEN_GENERATE_TREEVIEW YES)
    set(DOXYGEN_DISABLE_INDEX NO)
    set(DOXYGEN_FULL_SIDEBAR NO)
    set(DOXYGEN_HTML_COLORSTYLE	LIGHT) # required with Doxygen >= 1.9.5

    # --- DOT Graphs
    # Reference : https://jothepro.github.io/doxygen-awesome-css/md_docs_2tricks.html
    #(set DOXYGEN_HAVE_DOT YES) # Set to YES if the dot component was requested and found during FindPackage call.
    set(DOXYGEN_DOT_IMAGE_FORMAT svg)
    #set(DOT_TRANSPARENT YES) # Doxygen 1.9.8 report this line as obsolete

    # NOTE : As specified by docs, list will be properly handled by doxygen_add_docs : https://cmake.org/cmake/help/latest/module/FindDoxygen.html
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-darkmode-toggle.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-fragment-copy-button.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-paragraph-link.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-interactive-toc.js")
    list(APPEND DOXYGEN_HTML_EXTRA_FILES "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-tabs.js")

    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css)
    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css" [=[@TCM_DOXYGEN_HTML_EXTRA_STYLESHEET_DEFAULT@]=])

    list(APPEND DOXYGEN_ALIASES [[html_frame{1}="@htmlonly<iframe src=\"\1\"></iframe>@endhtmlonly"]])
    list(APPEND DOXYGEN_ALIASES [[html_frame{3}="@htmlonly<iframe src=\"\1\" width=\"\2\" height=\"\3\"></iframe>@endhtmlonly"]])
    list(APPEND DOXYGEN_ALIASES [[widget{2}="@htmlonly<div class=\"\1\" id=\"\2\"></div>@endhtmlonly"]])
    list(APPEND DOXYGEN_ALIASES [[Doxygen="[Doxygen](https://www.doxygen.nl/index.html)"]])
    list(APPEND DOXYGEN_ALIASES [[Doxygen-awesome="[Doxygen Awesome CSS](https://jothepro.github.io/doxygen-awesome-css/)"]])

    # ------------------------------------------------------------------------------
    # --- CONFIGURATION
    # ------------------------------------------------------------------------------
    doxygen_add_docs(docs)

    # Utility target to open docs
    add_custom_target(open_docs COMMAND "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html")
    add_dependencies(open_docs docs)
    tcm_section_end()

endfunction()