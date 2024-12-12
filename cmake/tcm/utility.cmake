# ------------------------------------------------------------------------------
#           File : utility.cmake
#         Author : TBlauwe
#    Description : Miscellaneous functions for logging and other handy functions.
# ------------------------------------------------------------------------------
include_guard()

# Define "-D${_option}" for _target when _option is ON.
function(target_option_define _target _option)
	if (${_option})
		target_compile_definitions(${_target} PUBLIC "${_option}")
	endif ()
endfunction()


# Prevent warnings from displaying when building target
# Useful when you do not want libraries warnings polluting your build output
# TODO Seems to work in some cases but not all.
function(suppress_warnings target)
	set_target_properties(${target} PROPERTIES INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${target},INTERFACE_INCLUDE_DIRECTORIES>)
endfunction()


# TODO Also look at embedding ?
# Copy folder _src_dir to _dst_dir before target is built.
function(target_assets _target _src_dir _dst_dir)
	add_custom_target(${_target}_copy_assets
			COMMAND ${CMAKE_COMMAND} -E copy_directory
			${_src_dir} ${_dst_dir}
			COMMENT "(${_target}) - Copying assets from directory ${_src_dir} to ${_dst_dir}"
	)
	add_dependencies(${_target} ${_target}_copy_assets)
endfunction()


# Indent cmake message
macro(indent)
	list(APPEND CMAKE_MESSAGE_INDENT "    ${ARGN}")
endmacro()


# ------------------------------------------------------------------------------
# --- DEV-MODE ONLY (noop otherwise)
# ------------------------------------------------------------------------------


# Outdent cmake messages
macro(outdent)
	list(POP_BACK CMAKE_MESSAGE_INDENT)
endmacro()


# Print a space
function(space)
	if(${PROJECT_IS_TOP_LEVEL})
		message("")
	endif()
endfunction()


# Print an opening header in cmake output. Don't forget to call end_section() afterwards !
# Needs to be a macro so indent works.
macro(section)
	if(${PROJECT_IS_TOP_LEVEL})
		message(CHECK_START "[${PROJECT_NAME}] " ${ARGN})
		indent()
	endif()
endmacro()


# Print a closing header. Take a condition to see if section failed or not.
# Needs to be a macro so indent works.
macro(end_section)
	set(opts)
	set(one_value_args)
	set(multi_value_args PASS FAIL CONDITION)
	cmake_parse_arguments(END_SECTION "${opts}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(${PROJECT_IS_TOP_LEVEL})
		outdent()
		if(ARGN)
			if(${END_SECTION_CONDITION})
				message(CHECK_PASS ${END_SECTION_PASS})
			else(})
				message(CHECK_FAIL ${END_SECTION_FAIL})
			endif()
		else ()
			message(CHECK_PASS "done")
		endif()
	endif()
endmacro()
