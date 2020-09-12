function(search_cppkg)
    cmake_parse_arguments(ARG "lib;bin;cmake" "VERSION" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(REMOVE_AT ARG_UNPARSED_ARGUMENTS 0)
    if(ARG_bin)
        find_program(find_bin NAMES ${name})
        if(NOT "${find_bin}" STREQUAL "find_bin-NOTFOUND")
            set(${name}_found TRUE  PARENT_SCOPE)
            set(${name}_path ${find_bin} PARENT_SCOPE)
        else()
            set(${name}_found FALSE PARENT_SCOPE)
        endif()
        unset(find_bin CACHE)
    elseif(ARG_cmake)

    else()
       find_package(${name} ${ARG_VERSION} ${ARG_UNPARSED_ARGUMENTS} QUIET)
       string(TOUPPER ${name} upper_name) 
       if(${${name}_FOUND} EQUAL 1 OR (${${upper_name}_FOUND}))
           set(${name}_found TRUE PARENT_SCOPE)
       else()
           set(${name}_found FALSE PARENT_SCOPE)
       endif()
       set(${name}_VERSION ${${name}_VERSION} PARENT_SCOPE)
       if("${${name}_VERSION}" STREQUAL "")
           set(${name}_VERSION ${${upper_name}_VERSION} PARENT_SCOPE)
       endif()
    endif()
endfunction()
