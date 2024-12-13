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