macro(_download_package)
    set(options LOCAL GLOBAL)
    set(oneValueArgs URL GIT GIT_TAG)
    set(multiValueArgs CMAKE_ARGS W_CONFIGURE W_BUILD W_INSTALL
                                  L_CONFIGURE L_BUILD L_INSTALL)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(GET ARG_UNPARSED_ARGUMENTS 1 version)
    list(REMOVE_AT ARG_UNPARSED_ARGUMENTS 0 1)

    set(NO_MESSAGE TRUE)
    cppm_setting()

    if(ARG_LOCAL)
      set(_INSTALL_PREFIX "-DCMAKE_INSTALL_PREFIX=${HOME}/.cppm/local ")
    elseif(ARG_GLOBAL)
      set(_INSTALL_PREFIX "")
    else()
      message(FATAL_ERROR "Need Option LOCAL or GLOBAL")
    endif()

    set(_version ${version})
    set(is_lastest FALSE)
    if(${version} STREQUAL "lastest")
      set(is_lastest TRUE)
      set(version "")
    endif()
    
    include(FetchContent)
    find_package(${name} ${version} QUIET)
    if(NOT "${${name}_FIND_VERSION_EXACT}" OR ${is_lastest})
      set(is_lastest TRUE)
    endif()

    if(NOT "${${name}_FOUND}" OR ${is_lastest})
        message(STATUS "[cppm] Can not find ${name} package")
        message(STATUS "[cppm] Download ${name} package")
        if(NOT EXISTS ${HOME}/.cppm/install/${name})
            file(MAKE_DIRECTORY ${HOME}/.cppm/install/${name})
        endif()
        if(NOT WIN32)
        FetchContent_Declare(
            ${name}
            URL ${ARG_URL}
            GIT_REPOSITORY ${ARG_GIT}
            GIT_TAG ${ARG_GIT_TAG}
            SOURCE_DIR ${HOME}/.cppm/install/${name}/${_version}
            CMAKE_ARGS ${CMAKE_ARGS} ${_INSTALL_PREFIX} ${ARG_CMAKE_ARGS}
            CONFIGURE_COMMAND ${ARG_L_CONFIGURE}
            BUILD_COMMAND ${ARG_L_BUILD}
            INSTALL_COMMAND ${ARG_L_INSTALL}
            BUILD_IN_SOURCE true
            ${ARG_UNPARSED_ARGUMENTS}
        )
        else(NOT WIN32)
        FetchContent_Declare(
            ${name}
            URL ${ARG_URL}
            GIT_REPOSITORY ${ARG_GIT}
            GIT_TAG ${ARG_GIT_TAG}
            SOURCE_DIR ${HOME}/.cppm/install/${name}/${_version}
            CMAKE_ARGS ${CMAKE_ARGS} ${_INSTALL_PREFIX} ${ARG_CMAKE_ARGS}
            CONFIGURE_COMMAND ${ARG_W_CONFIGURE}
            BUILD_COMMAND ${ARG_W_BUILD}
            INSTALL_COMMAND ${ARG_W_INSTALL}
            BUILD_IN_SOURCE true
            ${ARG_UNPARSED_ARGUMENTS}
        )
        endif(NOT WIN32)
        message(STATUS "[cppm] Cache Direcroty ${HOME}/.cppm/install/${name}/${_version}")
    else()
        message(STATUS "[cppm] Find ${name} package")
    endif()
endmacro()