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

option(DOX_INSTALL "Have `install` target produce documentation" OFF)
option(DOX_PUBLIC
    "Produce public-facing version of docs (hide to-dos, non-header source)"
    OFF)

# Save DocGenConfig.cmake's path at config-load-time.
set(DOX_CONFIG_DIR ${CMAKE_CURRENT_LIST_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DocGen DEFAULT_MSG DOXYGEN_FOUND)

if (DocGen_FIND_REQUIRED AND NOT TARGET Doxygen::doxygen)
    message(FATAL_ERROR "Missing Doxygen. Did you find_package(Doxygen)?")
endif ()

function(configure_doxygen)
    set(options )
    set(oneValueArgs MAINPAGE OPTIMIZE_C)
    set(multiValueArgs
            EXAMPLE_PATH
            EXCLUDE
            INPUT
            STRIP_INC_PATH)
    cmake_parse_arguments(DOX "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if (NOT TARGET Doxygen::doxygen)
        message(FATAL_ERROR "Missing Doxygen. Did you find_package(Doxygen)?")
    endif ()

    # Internal/public mode sets a lot of yes/no EXTRACT/HIDE and SOURCE_BROWSER
    # options in the Doxyfile.
    if (DOX_PUBLIC)
        set(DOXYGEN_INTERNAL_MODE NO)
        set(DOXYGEN_PUBLIC_MODE   YES)
    else ()
        set(DOXYGEN_INTERNAL_MODE YES)
        set(DOXYGEN_PUBLIC_MODE   NO)
    endif ()

    # If "README.md" is wanted for USE_MDFILE_AS_MAINPAGE, it must also be in INPUT
    if (DOX_MAINPAGE)
        list(APPEND DOX_INPUT "${DOX_MAINPAGE}")
    endif ()

    # Caller can speficy a separate EXAMPLE_PATH, or just put examples in an
    # INPUT source directory
    if (NOT DEFINED DOX_EXAMPLE_PATH)
        set(DOX_EXAMPLE_PATH ${DOX_INPUT})
    endif ()

    # Doxygen can optimize output for more functional C - but if C++, we should
    # err on the side of NOT optimizing for legacy code.
    if (DEFINED DOX_OPTIMIZE_C)
        if (DOX_OPTIMIZE_C) # Convert truthy/falsy to YES/NO
            set(DOXYGEN_OPTIMIZE_C YES)
        else ()
            set(DOXYGEN_OPTIMIZE_C NO)
        endif ()
    else ()
        get_property(ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
        if (C IN_LIST ENABLED_LANGUAGES AND NOT CXX IN_LIST ENABLED_LANGUAGES)
            set(DOXYGEN_OPTIMIZE_C YES)
        else ()
            set(DOXYGEN_OPTIMIZE_C NO)
        endif ()
    endif ()

    set(DOXYGEN_LOGO "${DOX_CONFIG_DIR}/resources/logo.png")

    # Rename input variables for injection into Doxyfile - makes an audit trail.
    set(                   DOXYGEN_MAINPAGE       "${DOX_MAINPAGE}")
    string(REPLACE ";" " " DOXYGEN_STRIP_INC_PATH "${DOX_STRIP_INC_PATH}")
    string(REPLACE ";" " " DOXYGEN_INPUT          "${DOX_INPUT}")
    string(REPLACE ";" " " DOXYGEN_EXCLUDE        "${DOX_EXCLUDE}")
    string(REPLACE ";" " " DOXYGEN_EXAMPLE_PATH   "${DOX_EXAMPLE_PATH}")

    configure_file("${DOX_CONFIG_DIR}/Doxyfile.in"
        "${PROJECT_BINARY_DIR}/Doxyfile" @ONLY)

    set(DOCS_ALL)
    if (DOX_INSTALL)
        # If adding to install target, ensure docs are built with ALL
        set(DOCS_ALL ALL)

        install(DIRECTORY ${PROJECT_BINARY_DIR}/html/
            DESTINATION share/doc/${PROJECT_NAME})
    endif()

    add_custom_target(docs ${DOCS_ALL}
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
        COMMAND "${DOXYGEN_EXECUTABLE}" "${PROJECT_BINARY_DIR}/Doxyfile")
endfunction()
