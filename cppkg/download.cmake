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

    if(NOT cppm_generator_type STREQUAL "visual-studio") ## visual studio build type problem 
        cppm_set(CMAKE_BUILD_TYPE "Release")
        set(cppm_build_type "release")
    endif()
    set_cache_check(${name}_cmake_args "${ARG_CMAKE_ARGS}" STRING)
    cppm_set_then(_recompile "TRUE" "_is_same" "FALSE")
    set_cache_check(${name}_version "${version}" STRING) 
    cppm_set_then(_recompile "TRUE" "_is_same" "FALSE")
    set_cache_check(${name}_build_type "${CMAKE_BUILD_TYPE}" STRING)
    cppm_set_then(_recompile "TRUE" "_is_same" "FALSE")

    set(_version ${version})
    if(version STREQUAL "git")
      set(version "")
      set(_is_git TRUE)
      find_package(${name} ${version} QUIET)
    else()
      find_package(${name} ${version} QUIET)
    endif()
    if(${${name}_FOUND} EQUAL 0)
        set(_recompile TRUE)
        cppkg_print("Can not find ${name} package")
    endif()

    if(ARG_GLOBAL)
      set(CMAKE_INSTALL_PREFIX "")
    else()
        if(_is_git)
            set(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${name}")
            set(_source_path ${CPPM_PKGS}/${name}/src)
        else()
            set(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${name}-${version}")
            set(_source_path ${CPPM_PKGS}/${name}-${version}/src)
        endif()
    endif()
    _cppm_rpath()
    set(_INSTALL_PREFIX "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}") 

    set(_cache_path ${CPPM_CACHE}/${name}/${_version})

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
    if(_recompile OR _is_git)
        if(NOT EXISTS ${_cache_path})
            file(MAKE_DIRECTORY ${_cache_path})
        endif()
        if(_is_git)
            include(download/git)
            hash_check(${_source_path} ${_cache_path})
        else()
            if(EXISTS ${_cache_path}/hash.cmake)
                include(${_cache_path}/hash.cmake)
            else()
                set(URL_HASH "")
            endif()
        endif()
        set(_binary_directory ${_cache_path}/build/${cppm_build_type}-${cppm_generator_type})
        #string(REPLACE ";" "|" CMAKE_PREFIX_PATH_ALT_SEP "${CMAKE_PREFIX_PATH}")
        if(NOT hash_matched OR (NOT EXISTS ${_binary_directory}) OR _recompile)
            cppkg_print("Download ${name} package")
            cppkg_print("Source Direcroty ${_source_path}")
            cppkg_print("Cache Direcroty ${_cache_path}")
            ExternalProject_Add(
                _${name}
                URL ${ARG_URL}
                URL_HASH MD5=${URL_HASH}
                GIT_REPOSITORY ${ARG_GIT}
                GIT_TAG ${ARG_GIT_TAG}
                DOWNLOAD_DIR ${_cache_path}
                DOWNLOAD_NO_PROGRESS TRUE
                DOWNLOAD_NO_EXTRACT TRUE
                SOURCE_DIR ${_source_path}
                BINARY_DIR ${_binary_directory}
        #        LIST_SEPARATOR |
                CMAKE_ARGS
                    ${CMAKE_ARGS}
                    #-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_ALT_SEP}
                    "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
                    ${_INSTALL_PREFIX} ${ARG_CMAKE_ARGS}
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    -G ${CMAKE_GENERATOR} -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                CONFIGURE_COMMAND ${_configure_cmd}
                BUILD_COMMAND ${_build_cmd}
                INSTALL_COMMAND cmake --build . --target install --config ${CMAKE_BUILD_TYPE}
                ${ARG_UNPARSED_ARGUMENTS}
            )

            install(DIRECTORY "${CMAKE_INSTALL_PREFIX}/bin/" DESTINATION ${CPPM_PREFIX}/bin USE_SOURCE_PERMISSIONS) 
            if(_is_git)
                write_hash(${_source_path} ${_cache_path})
            else()
                ExternalProject_Get_Property(_${name} DOWNLOADED_FILE)
                file(MD5 ${DOWNLOADED_FILE} _file_hash)
                set(hash_file ${_cache_path}/hash.cmake)
                set(file_data "set(URL_HASH \"${_file_hash}\")")
                file(WRITE "${hash_file}" "${file_data}")
            endif()
        endif()
    endif()
endmacro()




