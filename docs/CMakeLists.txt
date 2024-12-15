# ------------------------------------------------------------------------------ 
#           File : docs/CMakeList.txt
#         Author : TBlauwe
#    Description : CMake file to build docs using doxygen and doxygen awesome
# ------------------------------------------------------------------------------
section("Configuring documentation")


# ------------------------------------------------------------------------------
# --- Dependencies
# ------------------------------------------------------------------------------
# Doxygen is a documentation generator and static analysis tool for software source trees.
find_package(Doxygen QUIET)
if(NOT Doxygen_FOUND)
    message(AUTHOR_WARNING "Doxygen not found -> Skipping docs.")
	return()
endif()

# Doxygen awesome CSS is a custom CSS theme for doxygen html-documentation with lots of customization parameters.
CPMAddPackage(
        NAME DOXYGEN_AWESOME_CSS
		GIT_TAG "v2.3.2"
        GITHUB_REPOSITORY jothepro/doxygen-awesome-css
)
if(NOT DOXYGEN_AWESOME_CSS_ADDED)
    message(AUTHOR_WARNING "Could not add DOXYGEN_AWESOME_CSS -> Skipping docs.")
	return()
endif()


# ------------------------------------------------------------------------------
# --- Target : my_lib_docs & my_lib_open_docs
# ------------------------------------------------------------------------------
set(DOXYGEN_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/doxygen")
set(DOXYGEN_HTML_DIR "${DOXYGEN_OUTPUT_DIR}/html")
set(DOXYGEN_PAGES_DIR "${PROJECT_SOURCE_DIR}/docs/pages")
set(DOXYGEN_ASSETS_DIR "${PROJECT_SOURCE_DIR}/assets")
set(PROJECT_LOGO "${PROJECT_SOURCE_DIR}/assets/logo_small_dark.png")

configure_file(doxygen/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
configure_file(doxygen/header.html ${CMAKE_CURRENT_BINARY_DIR}/header.html)
configure_file(doxygen/footer.html ${CMAKE_CURRENT_BINARY_DIR}/footer.html)

file(GLOB_RECURSE DOCS_PAGES "pages/*.md")
file(GLOB_RECURSE DOCS_ASSETS "assets/*")

set(DOCS_DOXYGEN_FILES 
	"doxygen/Doxyfile.in"
	"doxygen/cppreference-doxygen-web.tag"
	"doxygen/header.html"
	"doxygen/footer.html"
	"doxygen/custom.css"
	"doxygen/DoxygenLayout.xml"
)

# This target runs a script to update each file that need to update code blocks based on an input file
add_custom_target(
	update_code_blocks
	COMMAND ${CMAKE_COMMAND} -DPROJECT_SOURCE_DIR="${PROJECT_SOURCE_DIR}" -P "${CMAKE_CURRENT_SOURCE_DIR}/update_code_blocks.cmake"
	SOURCES
		"${CMAKE_CURRENT_SOURCE_DIR}/update_code_blocks.cmake"
)

add_custom_target(
	docs
	COMMAND ${CMAKE_COMMAND} -E make_directory "${DOXYGEN_OUTPUT_DIR}"
	COMMAND ${CMAKE_COMMAND} -E make_directory "${DOXYGEN_HTML_DIR}"
	COMMAND ${CMAKE_COMMAND} -E copy_directory "${DOXYGEN_ASSETS_DIR}" "${DOXYGEN_HTML_DIR}"
	COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
	COMMAND echo "Docs written to: ${DOXYGEN_OUTPUT_DIR}"
	WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
	SOURCES
		${DOCS_DOXYGEN_FILES}
		${DOCS_PAGES}
		${DOCS_ASSETS}
)
add_dependencies(docs update_code_blocks)


# Utility target to open docs
add_custom_target(
	open_docs
	COMMAND "${DOXYGEN_OUTPUT_DIR}/html/index.html"
)
add_dependencies(open_docs docs)

end_section()