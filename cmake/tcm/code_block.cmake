# ------------------------------------------------------------------------------
#           File : code_block.cmake
#         Author : TBlauwe
#    Description : Generate markdown code blocks from a source.
#                  Included source file path must be relative to project source directory.
#                  File's extension is used to determine the code block language.
#                  If included files have not changed, then files will be left untouched.
#          Usage :
#                  // README.md
#
#                  <!--BEGIN_INCLUDE="relative_path/to/file.cpp"-->
#                  #Everything between this two tags will be replaced by the content of the file inside a code block.
#                  <!--END_INCLUDE-->
#
#                  // CMakeLists.txt
#                  include(tcm/code_block.cmake
#                  generate_code_blocks(README.md)
# ------------------------------------------------------------------------------
include_guard()

# Expects a file path, relative to project source directory.
function(generate_code_blocks FILENAME)
	message(CHECK_START "Looking for code-blocks to update in ${FILENAME}")

	if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${FILENAME})
		message(CHECK_FAIL "Skipping : file does not exist.")
		return()
	endif ()

	set(NEED_UPDATE FALSE)	# Update file when at least one code block was updated.
	set(STAMP_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/code-blocks")
	set(PATTERN "(<!--BEGIN_INCLUDE=\"(.*)\"-->)(.*)(<!--END_INCLUDE-->)")
	file(READ ${FILENAME} INPUT_CONTENT)
	string(REGEX MATCHALL ${PATTERN} matches ${INPUT_CONTENT})

	if(NOT matches)
		message(CHECK_FAIL "Skipping : no code-block found.")
		return()
	endif ()

	file(MAKE_DIRECTORY ${STAMP_OUTPUT_DIRECTORY})
	foreach(match ${matches})

		string(REGEX REPLACE ${PATTERN} "\\1;\\2;\\3;\\4" groups ${match})
		list(GET groups 0 HEADER)
		list(GET groups 1 FILE_PATH)
		list(GET groups 2 BODY)
		list(GET groups 3 FOOTER)

		# First, check if file needs updating.
		set(ABSOLUTE_INC_FILE_PATH "${PROJECT_SOURCE_DIR}/${FILE_PATH}")
		set(ABSOLUTE_STAMP_FILE_PATH "${STAMP_OUTPUT_DIRECTORY}/${FILE_PATH}.stamp")
		file(TIMESTAMP ${ABSOLUTE_INC_FILE_PATH} src_timestamp)
		file(TIMESTAMP ${ABSOLUTE_STAMP_FILE_PATH} dest_timestamp)

		if(${ABSOLUTE_INC_FILE_PATH} IS_NEWER_THAN ${ABSOLUTE_STAMP_FILE_PATH})
			set(NEED_UPDATE TRUE)
			get_filename_component(_DIR ${FILE_PATH} DIRECTORY)
			file(MAKE_DIRECTORY ${STAMP_OUTPUT_DIRECTORY}/${_DIR})
			file(TOUCH ${ABSOLUTE_STAMP_FILE_PATH})

			# Build new code block
			file(READ ${ABSOLUTE_INC_FILE_PATH} NEW_BODY)
			get_filename_component(FILEPATH_EXT ${FILE_PATH} EXT)
			string(REPLACE "." "" FILEPATH_EXT ${FILEPATH_EXT})
			string(REPLACE "${HEADER}${BODY}${FOOTER}" "${HEADER}\n```${FILEPATH_EXT}\n${NEW_BODY}\n```\n${FOOTER}" INPUT_CONTENT ${INPUT_CONTENT})
		endif ()
	endforeach()

	if(NEED_UPDATE) # At least one code block was updated.
		file(WRITE ${FILENAME} ${INPUT_CONTENT})
		message(CHECK_PASS "done.")
	else()
		message(CHECK_PASS "done. No code-blocks needed to be updated.")
	endif()
endfunction()