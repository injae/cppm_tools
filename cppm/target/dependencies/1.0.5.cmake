macro(_cppm_target_dependencies)
    cmake_parse_arguments(ARG "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    if(DEFINED ARG_PUBLIC)
        target_link_libraries(${name} PUBLIC ${ARG_PUBLIC})
    endif()
    if(DEFINED ARG_PRIVATE)
        target_link_libraries(${name} PRIVATE ${ARG_PRIVATE})
    endif()
    if(DEFINED ARG_INTERFACE)
        target_link_libraries(${name} INTERFACE ${ARG_INTERFACE})
    endif()
    set(deps)
    string(REPLACE " " "\n   - " pub_dep "${ARG_PRIVATE}")
    string(REPLACE ";" "\n   - " pub_dep "${ARG_PRIVATE}")
    list(APPEND deps "${pub_dep}")
    string(REPLACE " " "\n   - " pri_dep "${ARG_PUBLIC}")
    string(REPLACE ";" "\n   - " pri_dep "${ARG_PUBLIC}")
    list(APPEND deps "${pri_dep}")
    string(REPLACE " " "\n   - " int_dep "${ARG_INTERFACE}")
    string(REPLACE ";" "\n   - " int_dep "${ARG_INTERFACE}")
    list(APPEND deps "${int_dep}")
    string(REPLACE ";" " " deps "${deps}")
    message(STATUS "Dependencies:")
    message("   - ${deps}\n")
endmacro()
