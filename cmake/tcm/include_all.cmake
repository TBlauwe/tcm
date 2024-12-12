# ------------------------------------------------------------------------------
#           File : include_all.cmake
#         Author : TBlauwe
#    Description : Optional module to include all tcm modules in caller scope.
# ------------------------------------------------------------------------------
include_guard()

include(tcm/prevent_in_source_build)
if(PROJECT_IS_TOP_LEVEL)
    include(tcm/setup_cache)
endif ()
include(tcm/setup_version)
include(tcm/support_computed_gotos)
include(tcm/utility)
include(tcm/code_block)
include(tcm/warning_guard)