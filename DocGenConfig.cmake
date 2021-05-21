# Doxygen Document Generation Module - Doxygen Support
#
# Usage:
#
#     find_package(Doxygen)
#     find_package(DocGen)
#
#     if (DOCGEN_FOUND)
#         configure_doxygen(
#             MAINPAGE README.md
#             EXAMPLE_PATH "examples"
#             EXCLUDE "src/thatOneFile.cpp"
#             INPUT "src" "include"
#             STRIP_INC_PATH "include")
#     endif ()
#
# This will create a `docs` target for generating documentation, and will set up
# an additional install if DOX_INSTALL is set to ON. Documents will be
# installed to `[DESTDIR][prefix]/share/doc/<Project Name>`
#
# Arguments:
#
# * MAINPAGE - Doxygen can use a markdown file for your documentations home
#         page. This is passed directly to Doxyfile.in variable
#         USE_MDFILE_AS_MAINPAGE, and is added to INPUT for convenience.
# * EXAMPLE_PATH - relative paths (from PROJECT_SOURCE_DIR) to folders of
#         example sources and implementations.
#         If unspecified, this will be set to the value of INPUT.
# * EXCLUDE - files and/or folders to exclude from INPUT
# * INPUT - relative paths (from PROJECT_SOURCE_DIR) to source files/folders.
#         This is passed directly to Doxyfile.in INPUT variable
# * STRIP_INC_PATH - Paths to strip from headers in INPUT for display purposes.
#         Without this, a header intended to be included as
#         `#include <opi/foo.h>` may be displayed as `#include <foo.h>`.
#         Set to Doxyfile.in variable STRIP_FROM_INC_PATH
# * OPTIMIZE_C - Optimize Doxygen output for C language. When not specificied,
#         this value will be set based on whether or not C is the only language
#         enabled for the project
#
# > See comments in Doxyfile.in for more explanation on STRIP_FROM_INC_PATH,
# > INPUT, and other Doxygen variables mentioned above.
#
# Options:
#
# * DOX_INSTALL     - have `install` target produce docs. This is disabled by
#                      default as most of our targets do not want to install
#                      documents, but this still provides `make doc` for
#                      development.
# * DOX_PUBLIC      -  Generated documents will not contain internal information
#                      like to-do's, bugs, and copies of non-header sources.
#

cmake_minimum_required(VERSION 3.3)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(docgen DEFAULT_MSG DOXYGEN_FOUND)

include(DocGen-functions.cmake)
