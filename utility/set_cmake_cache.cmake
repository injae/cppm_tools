function(append_cache cache_var data type)
    set(spaced_string " ${${cache_var}} ")
    string(FIND "${spaced_string}" " ${data} " data_index)
    if(NOT data_index EQUAL -1)
        return()
    endif()
    string(COMPARE EQUAL "" "${${cache_var}}" is_empty)
    if(is_empty)
        set("${cache_var}" "${data}" CACHE "${type}" "${ARGN}" FORCE)
    else()
        set("${cache_var}" "${data} ${${cache_var}}" CACHE "${type}" "${message}" FORCE)
    endif()
endfunction()


function(set_cache cache_var data type)
    set(spaced_string " ${${cache_var}} ")
    string(FIND "${spaced_string}" " ${data} " data_index)
    if(NOT data_index EQUAL -1)
        return()
    endif()
    string(COMPARE EQUAL "${data}" "${${cache_var}}" is_same)
    if(NOT is_same)
        set("${cache_var}" "${data}" CACHE "${type}" "${ARGN}" FORCE)
    endif()
endfunction()

function(default_cache cache_var data type)
    set(spaced_string " ${${cache_var}} ")
    string(FIND "${spaced_string}" " ${data} " data_index)
    if(NOT data_index EQUAL -1)
        return()
    endif()
    string(COMPARE EQUAL "" "${${cache_var}}" is_empty)
    if(is_empty)
        set("${cache_var}" "${data}" CACHE "${type}" "${ARGN}" FORCE)
    endif()
endfunction()

function(set_cache_check cache_var data type)
    set(spaced_string " ${${cache_var}} ")
    string(FIND "${spaced_string}" " ${data} " data_index)
    if(NOT data_index EQUAL -1)
        set(_is_same TRUE PARENT_SCOPE)
        return()
    endif()
    string(COMPARE EQUAL "" "${${cache_var}}" is_empty)
    string(COMPARE EQUAL "${data}" "${${cache_var}}" is_same)
    if(is_empty OR (NOT is_same))
        set("${cache_var}" "${data}" CACHE "${type}" "${ARGN}" FORCE)
        set(_is_same FALSE PARENT_SCOPE)
    else()
        set(_is_same TRUE PARENT_SCOPE)
    endif()
endfunction()

macro(add_compiler_option cache_var data)
    append_cache("${cache_var}" "${data}" STRING "compiler options")
endmacro()
 
function(cppm_set cache_var data)
    if(${cache_var} STREQUAL "${data}")
        unset(${cache_var})
        set("${cache_var}" "${data}" CACHE INTERNAL "${ARGN}")
    else()
        set("${cache_var}" "${data}" CACHE INTERNAL "${ARGN}" FORCE)
    endif()
endfunction()

macro(cppm_set_then name else_var if_cond if_var )
    if(${if_cond})
        set(${name} ${if_var})
    else()
        set(${name} ${else_var})
    endif()
endmacro()

macro(cppm_set_if name if_cond if_var)
    if(${if_cond})
        set(${name} ${if_var})
    else()
        if(NOT DEFINED ${name})
            set(${name} )
        endif()
    endif()
endmacro()

