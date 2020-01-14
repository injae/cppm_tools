macro(download_package)
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
      set(CMAKE_INSTALL_PREFIX "${HOME}/.cppm/local")
    endif()
    set(_INSTALL_PREFIX "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}") 

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
        message(STATUS "[cppm] Can not find ${name} package")
    endif()

    set(_cache_path ${CPPM_SOURCE}/${name}/${_version})
    set(_source_path ${CPPM_CACHE}/${name}/${_version})

    if(WIN32)
        set(_configure_cmd "${ARG_W_CONFIGURE}")
        set(_build_cmd "${ARG_W_BUILD}")
        set(_install_cmd "${ARG_W_INSTALL}")
    else()
        set(_configure_cmd "${ARG_L_CONFIUGURE}")
        set(_build_cmd "${ARG_L_BUILD}")
        set(_install_cmd "${ARG_L_INSTALL}")
    endif()
    
    include(ExternalProject)
    if(_is_not_found OR _is_git)
        message(STATUS "[cppm] Download ${name} package")
        set(_download_package False)
        if(NOT EXISTS ${_cache_path})
            file(MAKE_DIRECTORY ${_cache_path})
            set(_download_package True)
        endif()
        if(_is_git)
            include(download/git)
            hash_check(${_source_path} ${_cache_path})
        endif()
        if(download_package)
            if(hash_matched)
                ExternalProject_Add(
                    _${name}
                    URL ${ARG_URL}
                    GIT_REPOSITORY ${ARG_GIT}
                    GIT_TAG ${ARG_GIT_TAG}
                    SOURCE_DIR ${_source_path}
                    BINARY_DIR ${_cache_path}
                    CMAKE_ARGS ${CMAKE_ARGS} ${_INSTALL_PREFIX} ${ARG_CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} -G ${CMAKE_GENERATOR}
                    CONFIGURE_COMMAND ${_configure_cmd}
                    BUILD_COMMAND ${_build_cmd}
                    INSTALL_COMMAND ${_install_cmd}
                    ${ARG_UNPARSED_ARGUMENTS}
                )
            endif()
            if(_is_git)
                write_hash(${_source_path} ${_cache_path})
            endif()
        endif()
        message(STATUS "[cppm] Source Direcroty ${CPPM_SOURCE}/${name}/${_version}")
        message(STATUS "[cppm] Cache Direcroty ${CPPM_CACHE}/${name}/${_version}")
    else()
        message(STATUS "[cppm] Find ${name} package")
    endif()
endmacro()



