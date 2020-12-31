function(cppm_target_dependencies)
    cmake_parse_arguments(ARG "" "" "PRIVATE;PUBLIC;INTERFACE" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    if(TARGET ${name})
        get_target_property(is_test ${name}_info CPPM_IS_TEST)
        get_target_property(cppm_type ${name}_info CPPM_TYPE)
        if(cppm_type MATCHES "HEADER_ONLY")
            set(_public    "INTERFACE")
            set(_private   "INTERFACE")
            set(_interface "INTERFACE")
        else()
            set(_public    "PUBLIC")
            set(_private   "PRIVATE")
            set(_interface "INTERFACE")
        endif()

        if(DEFINED ARG_PUBLIC)
            foreach(dep IN LISTS ARG_PUBLIC)
                get_target_property(module ${dep}_info CPPM_MODULE)
                get_target_property(flag ${dep}_info CPPM_OPTIONAL_FLAG)
                if(flag)
                    target_link_libraries(${name} ${_public} ${module})
                    get_target_property(desc ${dep}_info CPPM_DESCRIPTION)
                    get_target_property(call ${dep}_info CPPM_DEPEND)
                    if(NOT is_test)
                        cppm_print("${name} <== ${desc}")
                    endif()
                endif()
            endforeach()
            set_property(TARGET ${name}_info APPEND PROPERTY CPPM_DEPENDENCIES ${ARG_PUBLIC})
        endif() 
        if(DEFINED ARG_PRIVATE)
            foreach(dep IN LISTS ARG_PRIVATE)
                get_target_property(module ${dep}_info CPPM_MODULE)
                get_target_property(flag ${dep}_info CPPM_OPTIONAL_FLAG)
                if(flag)
                    target_link_libraries(${name} ${_private} ${module})
                    get_target_property(desc ${dep}_info CPPM_DESCRIPTION)
                    if(NOT is_test)
                        cppm_print("${name} <== ${desc}")
                    endif()
                endif()
            endforeach()
            set_property(TARGET ${name}_info APPEND PROPERTY CPPM_DEPENDENCIES ${ARG_PRIVATE})
        endif()
        if(DEFINED ARG_INTERFACE)
            foreach(dep IN LISTS ARG_INTERFACE)
                get_target_property(module ${dep}_info CPPM_MODULE)
                get_target_property(flag ${dep}_info CPPM_OPTIONAL_FLAG)
                if(flag)
                    target_link_libraries(${name} ${_interface} ${module})
                    get_target_property(desc ${dep}_info CPPM_DESCRIPTION)
                    if(NOT is_test)
                        cppm_print("${name} <== ${desc}")
                    endif()
                endif()
            endforeach()
            set_property(TARGET ${name}_info APPEND PROPERTY CPPM_DEPENDENCIES ${ARG_INTERFACE})
        endif()
    endif()
endfunction()
