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
    set(one_value_args
            DOXYGEN_AWESOME_VERSION
    )
    set(multi_value_args)
    cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_value_args}" "${multi_value_args}")

    tcm_section("Documentation")
    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm__default_value(arg_DOXYGEN_AWESOME_VERSION      "v2.3.4")
    tcm__default_value(DOXYGEN_USE_MDFILE_AS_MAINPAGE   "${PROJECT_SOURCE_DIR}/README.md")
    tcm__default_value(DOXYGEN_OUTPUT_DIRECTORY         "${CMAKE_CURRENT_BINARY_DIR}/doxygen")
    tcm__default_value(DOXYGEN_HTML_HEADER              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html")
    tcm__default_value(DOXYGEN_HTML_FOOTER              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html")
    tcm__default_value(DOXYGEN_LAYOUT_FILE              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/layout.xml")

    if(NOT EXISTS ${DOXYGEN_HTML_HEADER})
        tcm_info("Generating default html header")
        set(TMP_DOXYGEN_HTML_HEADER "${DOXYGEN_HTML_HEADER}.in")
        file(WRITE ${TMP_DOXYGEN_HTML_HEADER} [=[@TCM_DOXYGEN_HTML_HEADER_DEFAULT@]=])
        configure_file(${TMP_DOXYGEN_HTML_HEADER} ${DOXYGEN_HTML_HEADER})
    endif ()

    if(NOT EXISTS ${DOXYGEN_HTML_FOOTER})
        tcm_info("Generating default html footer")
        set(TMP_DOXYGEN_HTML_FOOTER "${DOXYGEN_HTML_FOOTER}.in")
        file(WRITE ${TMP_DOXYGEN_HTML_FOOTER} [=[@TCM_DOXYGEN_HTML_FOOTER_DEFAULT@]=])
        configure_file(${TMP_DOXYGEN_HTML_FOOTER} ${DOXYGEN_HTML_FOOTER})
    endif ()

    if(NOT EXISTS ${DOXYGEN_LAYOUT_FILE})
        tcm_info("Generating default layout file")
        file(WRITE ${DOXYGEN_LAYOUT_FILE} [=[@TCM_DOXYGEN_LAYOUT_FILE_DEFAULT@]=])
    endif ()

    if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css")
        tcm_info("Generating custom css.")
        file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css" [=[@TCM_DOXYGEN_HTML_EXTRA_STYLESHEET_DEFAULT@]=])
    endif()

    # ------------------------------------------------------------------------------
    # --- Dependencies
    # ------------------------------------------------------------------------------
    # Doxygen is a documentation generator and static analysis tool for software source trees.
    find_package(Doxygen REQUIRED dot QUIET)
    if(NOT Doxygen_FOUND)
        tcm_warn("Doxygen not found -> Skipping docs.")
        return()
    endif()

    # Doxygen awesome CSS is a custom CSS theme for doxygen html-documentation with lots of customization parameters.
    tcm_silence_cpm_package(DOXYGEN_AWESOME_CSS)
    CPMAddPackage(
            NAME DOXYGEN_AWESOME_CSS
            GIT_TAG ${arg_DOXYGEN_AWESOME_VERSION}
            GITHUB_REPOSITORY jothepro/doxygen-awesome-css
    )
    tcm_restore_message_log_level()
    if(NOT DOXYGEN_AWESOME_CSS_ADDED)
        tcm_warn("Could not add DOXYGEN_AWESOME_CSS -> Skipping docs.")
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
    list(APPEND DOXYGEN_HTML_EXTRA_FILES
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-darkmode-toggle.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-fragment-copy-button.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-paragraph-link.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-interactive-toc.js"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-tabs.js"
    )

    list(APPEND DOXYGEN_HTML_EXTRA_STYLESHEET
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome.css"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only.css"
            "${DOXYGEN_AWESOME_CSS_SOURCE_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css"
            "${CMAKE_CURRENT_BINARY_DIR}/doxygen/custom.css"
    )

    list(APPEND DOXYGEN_ALIASES
            [[html_frame{1}="@htmlonly<iframe src=\"\1\"></iframe>@endhtmlonly"]]
            [[html_frame{3}="@htmlonly<iframe src=\"\1\" width=\"\2\" height=\"\3\"></iframe>@endhtmlonly"]]
            [[widget{2}="@htmlonly<div class=\"\1\" id=\"\2\"></div>@endhtmlonly"]]
            [[Doxygen="[Doxygen](https://www.doxygen.nl/index.html)"]]
            [[Doxygen-awesome="[Doxygen Awesome CSS](https://jothepro.github.io/doxygen-awesome-css/)"]]
    )

    # ------------------------------------------------------------------------------
    # --- CONFIGURATION
    # ------------------------------------------------------------------------------
    tcm_log("Configuring tcm_Documentation.")
    doxygen_add_docs(tcm_Documentation)

    # Utility target to open docs
    add_custom_target(tcm_Documentation_Open COMMAND "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html")
    set_target_properties(${target_name} PROPERTIES FOLDER "Utility")
    add_dependencies(tcm_Documentation_Open tcm_Documentation)

endfunction()