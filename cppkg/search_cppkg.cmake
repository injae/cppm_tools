function(search_cppkg)
    cmake_parse_arguments(ARG "BIN;CMAKE" "VERSION" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(REMOVE_AT ARG_UNPARSED_ARGUMENTS 0)
    if(ARG_BIN)
        find_program(find_bin ${name})
        if("${find_bin}" STREQUAL "find_bin-NOTFOUND")
            set(${name}_found FALSE PARENT_SCOPE)
        else()
            set(${name}_found TRUE  PARENT_SCOPE)
            set(${name}_path ${find_bin} PARENT_SCOPE)
        endif()
    elseif(ARG_CMAKE)

    else()
       find_package(${name} ${ARG_VERSION} ${ARG_UNPARSED_ARGUMENTS} QUIET)
       if(${${name}_FOUND} EQUAL 0)
           set(${name}_found FALSE PARENT_SCOPE)
       else()
           set(${name}_found TRUE PARENT_SCOPE)
       endif()
        set(${name}_VERSION ${${name}_VERSION} PARENT_SCOPE)
    endif()
endfunction()
