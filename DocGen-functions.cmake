cmake_minimum_required(VERSION 3.3)

option(DOX_INSTALL "Have `install` target produce documentation" OFF)
option(DOX_PUBLIC
    "Produce public-facing version of docs (hide to-dos, non-header source)"
    OFF)

# Save DocGen-functions.cmake's path at config-load-time.
set(DOX_CONFIG_DIR ${CMAKE_CURRENT_LIST_DIR})

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
