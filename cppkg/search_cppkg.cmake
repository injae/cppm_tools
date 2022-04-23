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
       string(COMPARE EQUAL "${name}_DIR-NOTFOUND" "${${name}_DIR}" is_empty)
       if(${${name}_FOUND})
           set(${name}_found FALSE PARENT_SCOPE)
       elseif(${${name}_FOUND} EQUAL 0)
           set(${name}_found FALSE PARENT_SCOPE)
       elseif(is_empty)
           set(${name}_found FALSE PARENT_SCOPE)
       elseif(NOT ${${upper_name}_FOUND})
           set(${name}_found TRUE PARENT_SCOPE)
       else()
           set(${name}_found TRUE PARENT_SCOPE)
       endif()
       set(${name}_VERSION "${${name}_VERSION}" PARENT_SCOPE)
       if(${name}_VERSION STREQUAL "")
           set(${name}_VERSION "${${upper_name}_VERSION}" PARENT_SCOPE)
           if(${name}_VERSION STREQUAL "")
               set(${name}_VERSION "unknown" PARENT_SCOPE)
           endif()
       endif()
    endif()
endfunction()
