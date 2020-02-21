function(cppm_download_package)
    cmake_parse_arguments(ARG "" "GIT;GIT_TAG;VERSION;URL;PATH;INSTALL_SCRIPT" "" ${ARGN})
    list(LENGTH ARG_UNPARSED_ARGUMENTS size)
    if(${size} LESS 1)
        message(FATAL_ERROR "You must provide a name")
    endif()
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)


    if(DEFINED ARG_VERSION)
        set(VERSION ${ARG_VERSION})
    else()
        if(DEFINED ARG_GIT)
            if(DEFINED ARG_GIT_TAG)
                set(VERSION ${ARG_GIT_TAG})
            else()
                set(VERSION git)
            endif()
        else()
            set(VERSION unknown)
        endif()
    endif()

    if(NOT ARG_PATH)
        set(ARG_PATH ${CPPM_SOURCE}/${name}/${VERSION})
    endif()

    set(_cache_path "${CPPM_CACHE}/${name}/${VERSION}")
    set(_install_script "${CPPM_CACHE}/${name}/${VERSION}/install-script")

    file(WRITE "${_install_script}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.2)\n"
        "project(CPPM_TOOL_DOWNLOAD VERSION ${CPPM_VERSION} NONE)\n"
        "include(ExternalProject)\n"
        "ExternalProject_Add(\n"
        "    ${name}\n"
        "    GIT_REPOSITORY ${ARG_GIT}\n"
        "    GIT_TAG        ${ARG_GIT_TAG}"
        "    URL            ${ARG_URL}"
        "    SOURCE_DIR     ${ARG_PATH}"
        "    BINARY_DIR     ${_cache_path}/build"
        "    CONFIGURE_COMMAND \"${INSTALL_SCRIPT}\""
        "    BUILD_COMMAND \"\"\n"
        "    INSTALL_COMMAND \"\"\n"
        ")\n"
    )
    execute_process(COMMAND cmake . WORKING_DIRECTORY ${_install_script} OUTPUT_QUIET)
    execute_process(COMMAND cmake  --build . WORKING_DIRECTORY ${_install_script} OUTPUT_QUIET)
    message(STATUS "[cppm] ${name} download to ${ARG_PATH}")
endfunction()
