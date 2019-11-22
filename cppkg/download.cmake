macro(download_package)
    set(options LOCAL GLOBAL)
    set(oneValueArgs URL URL_HASH GIT GIT_TAG)
    set(multiValueArgs CMAKE_ARGS W_CONFIGURE W_BUILD W_INSTALL
                                  L_CONFIGURE L_BUILD L_INSTALL)
    string(REPLACE ";" " " copy_argn "${ARGN}")
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(GET ARG_UNPARSED_ARGUMENTS 1 version)
    list(REMOVE_AT ARG_UNPARSED_ARGUMENTS 0 1)

    cppm_print("cppkg  [${name}/${version}] loading...")
    cppm_print("cppkg options ${copy_argn}")
    cppm_setting(NO_MESSAGE)

    set(CMAKE_ARGS ${CMAKE_ARGS} ${ARG_CMAKE_ARGS})
    list(REMOVE_ITEM multiValueArgs "CMAKE_ARGS")
    set(is_none_cmake_package FALSE)
    foreach(_option ${multiValueArgs})
        if(DEFINED "ARG_${_option}")
            set(is_none_cmake_package TRUE)
        endif()
    endforeach()

    include(${CPPM_VERSION}/cppkg/download-none-cmake-package)
    _none_cmake_download_package("${copy_argn}")
    #if(is_none_cmake_package)
    #    # use ExternalProject_add
    #else()
    #    set(CMAKE_PROJECT_NAME ${name})
    #    set(CMAKE_BUILD_TYPE RELEASE)
    #    set(NO_MESSAGE TRUE)
    #    if(ARG_LOCAL)
    #        set(CMAKE_INSTALL_PREFIX "${HOME}/.cppm/local")
    #    elseif(ARG_GLOBAL)
    #        set(CMAKE_INSTALL_PREFIX "")
    #    else()
    #        message(FATAL_ERROR "Need Option LOCAL or GLOBAL")
    #    endif()

    #    include(FetchContent)
    #    set(_package_install_path "${CPPM_ROOT}/install/${name}/${version}")
    #    FetchContent_Populate(
    #        ${name}
    #        GIT_REPOSITORY ${ARG_GIT}
    #        GIT_TAG        ${ARG_GIT_TAG}
    #        URL            ${ARG_URL}
    #        URL_HASH       ${ARG_URL_HASH}
    #        SOURCE_DIR    "${_package_install_path}/src"
    #        BINARY_DIR    "${_package_install_path}/build"
    #        SUBBUILD_DIR  "${_package_install_path}/cache"
    #        QUIET
    #    )
    #    add_subdirectory("${${name}_SOURCE_DIR}" "${${name}_BINARY_DIR}") 
    #    #execute_process(COMMAND cmake -P cmake_install.cmake
    #    #                RESULT_VARIABLE result
    #    #                WORKING_DIRECTORY ${_package_install_path}/build)
    #    #if(_is_not_found)
    #    #    message(STATUS "[cppm] Cache Direcroty ${HOME}/.cppm/install/${name}/${_version}")
    #    #    message(STATUS "[cppm] Find ${name} package")
    #    #endif()
    #endif()
endmacro()
