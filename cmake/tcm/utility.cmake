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





# ------------------------------------------------------------------------------
# --- DEV-MODE ONLY (noop otherwise)
# ------------------------------------------------------------------------------
