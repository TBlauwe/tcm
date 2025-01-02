# ------------------------------------------------------------------------------
# --- SETUP-DOCUMENTATION
# ------------------------------------------------------------------------------
# Description:
#   Setup documentation using doxygen and doxygen-awesome.

function(tcm_setup_docs)
    set(one_value_args
            ASSETS
            DOXYGEN_AWESOME_VERSION
    )
    set(multi_value_args
            FILES
    )
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "${one_value_args}" "${multi_value_args}")
    tcm_check_proper_usage(${CMAKE_CURRENT_FUNCTION} arg "$" "${one_value_args}" "${multi_value_args}" "")

    tcm_section("Documentation")
    # ------------------------------------------------------------------------------
    # --- Default values
    # ------------------------------------------------------------------------------
    tcm_default_value(arg_DOXYGEN_AWESOME_VERSION      "v2.3.4")
    tcm_default_value(DOXYGEN_USE_MDFILE_AS_MAINPAGE   "${PROJECT_SOURCE_DIR}/README.md")
    tcm_default_value(DOXYGEN_OUTPUT_DIRECTORY         "${CMAKE_CURRENT_BINARY_DIR}/doxygen")
    tcm_default_value(DOXYGEN_HTML_HEADER              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/header.html")
    tcm_default_value(DOXYGEN_HTML_FOOTER              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/footer.html")
    tcm_default_value(DOXYGEN_LAYOUT_FILE              "${CMAKE_CURRENT_BINARY_DIR}/doxygen/layout.xml")
    if(DOXYGEN_USE_MDFILE_AS_MAINPAGE)
        list(APPEND arg_FILES ${PROJECT_SOURCE_DIR}/README.md)
    endif ()

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
    if(NOT DOXYGEN_AWESOME_CSS_SOURCE_DIR)
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
    list(APPEND DOXYGEN_VERBATIM_VARS DOXYGEN_ALIASES)

    # ------------------------------------------------------------------------------
    # --- CONFIGURATION
    # ------------------------------------------------------------------------------
    tcm_log("Configuring ${PROJECT_NAME}_Documentation.")
    doxygen_add_docs(${PROJECT_NAME}_Documentation ${arg_FILES})

    #TODO Maybe use DOXYGEN_IMAGE_PATH to let doxygen handle copying ? But what about others assets (is there) ?
    if(arg_ASSETS)
        tcm_target_copy_assets(${PROJECT_NAME}_Documentation
                FILES ${arg_ASSETS}
                OUTPUT_DIR "${DOXYGEN_OUTPUT_DIRECTORY}/html/assets"
        )

    endif ()

    # Utility target to open docs
    add_custom_target(${PROJECT_NAME}_Documentation_Open COMMAND "${DOXYGEN_OUTPUT_DIRECTORY}/html/index.html")
    set_target_properties(${target_name} PROPERTIES FOLDER "Utility")
    add_dependencies(${PROJECT_NAME}_Documentation_Open ${PROJECT_NAME}_Documentation)

endfunction()