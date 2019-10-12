macro(_none_cmake_download_package)
    set(options LOCAL GLOBAL)
    set(oneValueArgs URL GIT GIT_TAG)
    set(multiValueArgs CMAKE_ARGS W_CONFIGURE W_BUILD W_INSTALL
                                  L_CONFIGURE L_BUILD L_INSTALL)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(GET ARG_UNPARSED_ARGUMENTS 1 version)
    list(REMOVE_AT ARG_UNPARSED_ARGUMENTS 0 1)

    cppm_setting(NO_MESSAGE)

    if(ARG_LOCAL)
      set(CMAKE_INSTALL_PREFIX "${HOME}/.cppm/local")
    elseif(ARG_GLOBAL)
      set(CMAKE_INSTALL_PREFIX "")
    else()
      message(FATAL_ERROR "Need Option LOCAL or GLOBAL")
    endif()

    set(_version ${version})
    if(${version} STREQUAL "git")
      set(version "")
      set(_is_git TRUE)
      find_package(${name} ${version} QUIET)
    else()
      find_package(${name} ${version} EXACT QUIET)
    endif()

    if(${${name}_FOUND} EQUAL 0)
        set(_is_not_found TRUE)
    endif()
    
    include(FetchContent)
    include(ExternalProject)
    if(_is_not_found OR _is_git)
        message(STATUS "[cppm] Can not find ${name} package")
        message(STATUS "[cppm] Download ${name} package")
        if(NOT EXISTS ${HOME}/.cppm/install/${name})
            file(MAKE_DIRECTORY ${HOME}/.cppm/install/${name})
        endif()
        if(NOT WIN32)
          ExternalProject_Add(
            _${name}
            URL ${ARG_URL}
            GIT_REPOSITORY ${ARG_GIT}
            GIT_TAG ${ARG_GIT_TAG}
            SOURCE_DIR ${HOME}/.cppm/install/${name}/${_version}
            BINARY_DIR ${HOME}/.cppm/install/${name}/${_version}-build-${CMAKE_GENERATOR}
            CMAKE_ARGS ${CMAKE_ARGS} ${_INSTALL_PREFIX} ${ARG_CMAKE_ARGS} -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -G ${CMAKE_GENERATOR}
            CONFIGURE_COMMAND ${ARG_L_CONFIGURE}
            BUILD_COMMAND ${ARG_L_BUILD}
            INSTALL_COMMAND ${ARG_L_INSTALL}
            ${ARG_UNPARSED_ARGUMENTS}
          )
        else(NOT WIN32)
          ExternalProject_Add(
            _${name}
            URL ${ARG_URL}
            GIT_REPOSITORY ${ARG_GIT}
            GIT_TAG ${ARG_GIT_TAG}
            SOURCE_DIR ${HOME}/.cppm/install/${name}/${_version}
            BINARY_DIR ${HOME}/.cppm/install/${name}/${_version}-build-${CMAKE_GENERATOR}
            CMAKE_ARGS ${CMAKE_ARGS} ${_INSTALL_PREFIX} ${ARG_CMAKE_ARGS} -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -G ${CMAKE_GENERATOR}
            CONFIGURE_COMMAND ${ARG_W_CONFIGURE}
            BUILD_COMMAND ${ARG_W_BUILD}
            INSTALL_COMMAND ${ARG_W_INSTALL}
            ${ARG_UNPARSED_ARGUMENTS}
          )
        endif(NOT WIN32)
        message(STATUS "[cppm] Cache Direcroty ${HOME}/.cppm/install/${name}/${_version}")
    else()
        message(STATUS "[cppm] Find ${name} package")
    endif()
endmacro()