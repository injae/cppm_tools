macro(cppm_target_dependencies)
    cmake_parse_arguments(ARG "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    if(${_O_${name}})
        if(NOT DEFINED _D_${name})
            set(_D_${name})
        endif()
        if(DEFINED ARG_PUBLIC)
            foreach(pub IN LISTS ARG_PUBLIC)
                target_link_libraries(${name} PUBLIC $<TARGET_PROPERTY:${pub},MODULE>)
                get_target_property(desc ${pub} DESCRIPTION)
                cppm_print("cppm <== ${desc}")
            endforeach()
            set_property(TARGET ${name} APPEND PROPERTY DEPENDENCIES ${ARG_PUBLIC})
            set_property(TARGET ${name} APPEND PROPERTY DEPENDENCIES ${ARG_PUBLIC})
            list(APPEND _D_${name} "${ARG_PUBLIC}")
        endif() 
        if(DEFINED ARG_PRIVATE)
            foreach(pri IN LISTS ARG_PRIVATE)
                target_link_libraries(${name} PRIVATE $<TARGET_PROPERTY:${pri},MODULE>)
                cppm_print("cppm <== ${pri}/${_V_${pub}}")
            endforeach()
            list(APPEND _D_${name} "${ARG_PRIVATE}")
        endif()
        if(DEFINED ARG_INTERFACE)
            foreach(intf IN LISTS ARG_INTERFACE)
                target_link_libraries(${name} INTERFACE $<TARGET_PROPERTY:${intf},MODULE>)
                cppm_print("cppm <== ${intf}/${_V_${pub}}")
            endforeach()
            list(APPEND _D_${name} "${ARG_INTERFACE}")
        endif()
    endif()
endmacro()

    #if(has_deps)
    #    set(deps)
    #    string(REPLACE " " "\n-- [cppm]    " pub_dep "${ARG_PRIVATE}")
    #    string(REPLACE ";" "\n-- [cppm]    " pub_dep "${ARG_PRIVATE}")
    #    list(APPEND deps "${pub_dep}")
    #    string(REPLACE " " "\n-- [cppm]    " pri_dep "${ARG_PUBLIC}")
    #    string(REPLACE ";" "\n-- [cppm]    " pri_dep "${ARG_PUBLIC}")
    #    list(APPEND deps "${pri_dep}")
    #    string(REPLACE " " "\n-- [cppm]    " int_dep "${ARG_INTERFACE}")
    #    string(REPLACE ";" "\n-- [cppm]    " int_dep "${ARG_INTERFACE}")
    #    list(APPEND deps "${int_dep}")
    #    string(REPLACE ";" " " deps "${deps}")
    #    message(STATUS "[cppm] Dependencies:")
    #    message(STATUS "[cppm]    ${deps}")
    #endif()
