macro(_cppm_project)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    if(NOT ${CMAKE_PROJECT_NAME} MATCHES ${PROJECT_NAME})
        set(SUB_PROJECT TRUE)
        set(NO_MESSAGE TRUE)
    endif()
endmacro()
