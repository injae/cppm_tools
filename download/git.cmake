function(git_clone)
    cmake_parse_arguments(ARG "QUIET" "URL;BRANCH;PATH" "" ${ARGN})
    list(LENGTH ARG_UNPARSED_ARGUMENTS size)
    if(${size} LESS 1)
        message(FATAL_ERROR "You must provide a name")
    endif()
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    find_package(Git REQUIRED)
    if(NOT GIT_FOUND)
        message(FATAL_ERROR "git not found!")
    endif()

    if(NOT ARG_URL)
        message(FATAL_ERROR "You must provide a git url")
    endif()

    if(NOT ARG_BRANCH)
        set(ARG_BRANCH master)
    endif()

    if(NOT ARG_PATH)
        set(ARG_PATH ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    if(NOT EXISTS ${ARG_PATH})
        make_directory(${ARG_PATH})
    endif()

    if(EXISTS ${ARG_PATH}/${name})
        if(NOT ARG_QUIET)
            message(STATUS "[cppm] Updating ${name}")
        endif()
            execute_process(
                COMMAND ${GIT_EXECUTABLE} fetch --all
                COMMAND ${GIT_EXECUTABLE} reset --hard origin/${ARG_BRANCH}
                WORKING_DIRECTORY ${ARG_PATH}/${name}
                OUTPUT_VARIABLE output
                )
    else()
        if(NOT ARG_QUIET)
            message(STATUS "[cppm] Downloading ${name}")
        endif()
            execute_process(
                COMMAND ${GIT_EXECUTABLE} clone ${ARG_URL} ${name} --recursive
                WORKING_DIRECTORY ${ARG_PATH}
                OUTPUT_VARIABLE output
                )
            if(NOT ARG_QUIET)
                message(STATUS "[cppm] ${output}")
            endif()

            if(NOT ${ARG_BRANCH} MATCHES "master")
                excute_process(
                    COMMAND ${GIT_EXCUTEABLE} checkout ${ARG_BRANCH}
                    WORKING_DIRECTORY ${ARG_PATH}/${name}
                    OUTPUT_VARIABLE output
                    )
            endif()
    endif()

    if(NOT ARG_QUIET)
        message(STATUS "[cppm] ${output}")
    endif()
endfunction()

function(hash_check src_path cache_path)
    set(hash_file ${cache_path}/git_hash.cmake)
    set(hash_matched FALSE PARENT_SCOPE)
    if(EXISTS ${hash_file})
        include(${hash_file})
        execute_process(
            COMMAND git rev-parse --short HEAD
            RESULT_VARIABLE result
            OUTPUT_VARIABLE short_hash
            WORKING_DIRECTORY ${src_path}
        )
        if(${short_hash} STREQUAL ${GIT_HASH})
            set(hash_matched TRUE PARENT_SCOPE)
        endif()
    endif()
endfunction()

function(write_hash src_path cache_path)
    execute_process(
        COMMAND git rev-parse --short HEAD
        RESULT_VARIABLE result
        OUTPUT_VARIABLE short_hash
        WORKING_DIRECTORY ${src_path}
    )
    set(hash_file ${cache_path}/git_hash.cmake)
    set(file_data "set(GIT_HASH ${short_hash})")
    set(hash_matched )
    if(EXISTS ${hash_file})
        include(${cache_path}/git_hash.cmake)
        if(${short_hash} STREQUAL ${GIT_HASH})
            set(hash_matched ON PARENT_SCOPE)
        endif()
    else()
        file(WRITE ${path}/git_hash.cmake ${file_data})
    endif()
endfunction()
