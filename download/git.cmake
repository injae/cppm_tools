find_package(Git REQUIRED)
if(NOT GIT_FOUND)
    message(FATAL_ERROR "git not found!")
endif()

function(git_clone)
    cmake_parse_arguments(ARG "QUIET" "URL;BRANCH;PATH" "" ${ARGN})
    list(LENGTH ARG_UNPARSED_ARGUMENTS size)
    if(${size} LESS 1)
        message(FATAL_ERROR "You must provide a name")
    endif()
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    if(NOT ARG_URL)
        message(FATAL_ERROR "You must provide a git url")
    endif()

    if(NOT ARG_BRANCH)
        set(ARG_BRANCH master)
    endif()

    if(NOT ARG_PATH)
        set(ARG_PATH ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    if(EXISTS ${ARG_PATH}/${name})
        message(STATUS "[cppm] updating cppm tool")
        execute_process(
            COMMAND ${GIT_EXECUTALBE} fetch -all
            COMMAND ${GIT_EXECUTALBE} reset --hard origin/${ARG_BRANCH}
            COMMAND ${GIT_EXECUTALBE} fetch pull origin ${ARG_BRANCH}
            WORKING_DIRECTORY ${ARG_PATH}/${name}
            OUTPUT_VARIABLE output
            )
    else()
        message(STATUS "[cppm] downloading cppm tool")
        execute_process(
            COMMAND ${GIT_EXECUTALBE} clone ${ARG_URL} --recursive
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
