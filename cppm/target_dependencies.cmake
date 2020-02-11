macro(cppm_target_dependencies)
    cmake_parse_arguments(ARG "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    set(has_deps FALSE)

    if(DEFINED ARG_PUBLIC)
        foreach(pub IN LISTS ARG_PUBLIC)
            target_link_libraries(${name} PUBLIC ${_M_${pub}})
        endforeach()
        set(has_deps TRUE)
    endif() 
    if(DEFINED ARG_PRIVATE)
        foreach(pri IN LISTS ARG_PRIVATE)
            target_link_libraries(${name} PRIVATE ${_M_${pri}})
        endforeach()
        set(has_deps TRUE)
    endif()
    if(DEFINED ARG_INTERFACE)
        foreach(intf IN LISTS ARG_INTERFACE)
            target_link_libraries(${name} INTERFACE ${_M_${intf}})
        endforeach()
        set(has_deps TRUE)
    endif()
    if(has_deps)
        set(deps)
        string(REPLACE " " "\n-- [cppm]    " pub_dep "${ARG_PRIVATE}")
        string(REPLACE ";" "\n-- [cppm]    " pub_dep "${ARG_PRIVATE}")
        list(APPEND deps "${pub_dep}")
        string(REPLACE " " "\n-- [cppm]    " pri_dep "${ARG_PUBLIC}")
        string(REPLACE ";" "\n-- [cppm]    " pri_dep "${ARG_PUBLIC}")
        list(APPEND deps "${pri_dep}")
        string(REPLACE " " "\n-- [cppm]    " int_dep "${ARG_INTERFACE}")
        string(REPLACE ";" "\n-- [cppm]    " int_dep "${ARG_INTERFACE}")
        list(APPEND deps "${int_dep}")
        string(REPLACE ";" " " deps "${deps}")
        message(STATUS "[cppm] Dependencies:")
        message(STATUS "[cppm]    ${deps}")
    endif()
endmacro()
