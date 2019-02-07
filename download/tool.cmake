function(download)
    cmake_parse_arguments(ARG "" "GIT_URL;URL;PATH" "" ${ARGN})
    list(LENGTH ARG_UNPARSED_ARGUMENTS size)
    if(${size} LESS 1)
        message(FATAL_ERROR "You must provide a name")
    endif()
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    if(NOT ARG_PATH)
        set(ARG_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${name})
    else()
        set(ARG_PATH ${ARG_PATH}/${name})
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
        "    GIT_REPOSITORY ${ARG_GIT_URL}\n"
        "    URL            ${ARG_URL}"
        "    SOURCE_DIR \"${ARG_PATH}\"\n"
        "    CONFIGURE_COMMAND \"\"\n"
        "    BUILD_COMMAND \"\"\n"
        "    INSTALL_COMMAND \"\"\n"
        ")\n"
    )
    execute_process(COMMAND ${CMAKE_COMMAND} .
                    WORKING_DIRECTORY ${build_dir})
    execute_process(COMMAND ${CMAKE_COMMAND}  --build .
                    WORKING_DIRECTORY ${build_dir})
endfunction()
