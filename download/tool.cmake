function(cppm_download_package)
    cmake_parse_arguments(ARG "" "GIT;GIT_TAG;URL;PATH;INSTALL_SCRIPT" "" ${ARGN})
    list(LENGTH ARG_UNPARSED_ARGUMENTS size)
    if(${size} LESS 1)
        message(FATAL_ERROR "You must provide a name")
    endif()
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    if(NOT ARG_PATH)
        set(ARG_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${name})
    else()
    endif()

    set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/tool/download/${name}")

    file(REMOVE_RECURSE "${build_dir}")
    #file(REMOVE_RECURSE "${build_dir}/CMakeLists.txt")
    file(MAKE_DIRECTORY ${build_dir})

    file(WRITE "${build_dir}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.2)\n"
        "project(CPPM_TOOL_DOWNLOAD LANGUAGES NONE)\n"
        "include(ExternalProject)\n"
        "ExternalProject_Add(\n"
        "    ${name}\n"
        "    GIT_REPOSITORY ${ARG_GIT}\n"
        "    GIT_TAG        ${ARG_GIT_TAG}"
        "    URL            ${ARG_URL}"
        "    SOURCE_DIR     ${ARG_PATH}"
        "    CONFIGURE_COMMAND \"${INSTALL_SCRIPT}\""
        "    BUILD_COMMAND \"\"\n"
        "    INSTALL_COMMAND \"\"\n"
        ")\n"
    )
    execute_process(COMMAND ${CMAKE_COMMAND} . WORKING_DIRECTORY ${build_dir} OUTPUT_QUIET)
    execute_process(COMMAND ${CMAKE_COMMAND}  --build . WORKING_DIRECTORY ${build_dir} OUTPUT_QUIET)
    message(STATUS "[cppm] ${name} download to ${ARG_PATH}")
endfunction()
