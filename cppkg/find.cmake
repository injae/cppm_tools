function(add_cppkg_info name)
    cmake_parse_arguments(ARG "" "VERSION;DEPEND" "MODULE" ${ARGN})
    if(TARGET ${name}_info)
    else()
        add_custom_target(${name}_info COMMENT "Cppkg Info Target")
    endif()

    set_target_properties(${name}_info PROPERTIES
        CPPM_MODULE "${ARG_MODULE}"
        CPPM_VERSION ${ARG_VERSION}
        CPPM_DEPEND  "${ARG_DEPEND}"
        CPPM_DESCRIPTION "${name}/${ARG_VERSION}"
    )
endfunction()

function(find_cppkg)
    cmake_parse_arguments(ARG "HUNTER" "" "MODULE;COMPONENTS;LOADPATH" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(GET ARG_UNPARSED_ARGUMENTS 1 version)
    set(version_ ${version})

    if(version STREQUAL "latest" OR (version STREQUAL "git"))
      set(version "")
      set(_recompile TRUE)
    else()
      set(_recompile FALSE)
    endif()

    if(DEFINED ARG_COMPONENTS)
        set(component_script COMPONENTS ${ARG_COMPONENTS})
    else()
        set(component_script)
    endif()

    if(ARG_HUNTER) 
        hunter_add_package(${name} ${component_script})
        cppm_print("Load Package ${name} from Hunter")
    endif()

    if(NOT DEFINED ARG_LOADPATH)
        if(cppm_detect_vcpkg)
            find_package(${name} ${version} ${component_script} QUIET)
        else()
            find_package(${name} ${version} ${component_script} EXACT QUIET)
        endif()
        if(NOT ${${name}_FOUND})
            set(_recompile TRUE)
        endif()
    endif()

    set(_cppkg "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/${name}.cmake.in") 
    if(EXISTS ${_cppkg})
        cppm_set_if(_recompile "TRUE" "cppm_build_type_change")
        file(SHA256 ${_cppkg} _cppkg_hash)
        set_cache_check(${PROJECT_NAME}_${name}_${version_}_hash ${_cppkg_hash} STRING)
        cppm_print("${_recompile}" ${_is_same})
        if(NOT _is_same AND (_recompile))
        message("==>[[${name}]]")
            configure_file(thirdparty/${name}/${version_}/${name}.cmake.in
                        ${CMAKE_BINARY_DIR}/thirdparty/${name}/${version_}/CMakeLists.txt)
            execute_process(COMMAND
                            ${CMAKE_COMMAND}
                            "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
                            "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}" .
                            RESULT_VARIABLE result
                            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/thirdparty/${name}/${version_})
            execute_process(COMMAND cmake --build . --config ${CMAKE_BUILD_TYPE}
                            RESULT_VARIABLE result
                            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/thirdparty/${name}/${version_})
        message("<==[[${name}]]")
        endif()
    endif()
    if(DEFINED ARG_LOADPATH)
        add_cppkg_info(${name}
             MODULE  "${ARG_MODULE}"
             VERSION "${version_}"
             DEPEND  "${PROJECT_NAME}"
        )
        set_target_properties(${name}_info PROPERTIES CPPM_LOADPATH "${ARG_LOADPATH}")
        if(NOT ARG_LOADPATH MATCHES "^\.\./.*$") # out of tree dependency(workspace) use this option
            message("==>[[${name}]]")
            add_subdirectory(${ARG_LOADPATH})
            message("<==[[${name}]]")
        else()
            cppkg_print("Load Workspace ${name}/${version_} from ${ARG_LOADPATH}")
        endif()
    else()
        find_package(${name} ${version} ${component_script} QUIET)

        if(NOT (${${name}_FOUND}))
            cppkg_print("Can't find Package: ${name}/${version} from Cppkg")
            find_package(${name} ${component_script} QUIET)
            if(${${name}_FOUND})
                cppkg_print("Find Alternative Package: ${name}/${${name}_VERSION} from Cppkg")
            endif()
        endif()

        if(${${name}_FOUND})
            cppkg_print("Load Package: ${name}/${${name}_VERSION} from Cppkg")
            add_cppkg_info(${name}
                MODULE  "${ARG_MODULE}"
                VERSION "${${name}_VERSION}"
                DEPEND  "${PROJECT_NAME}"
            )
        else()
            cppm_error_print("Can't find Package ${name}/${${name}_VERSION}")
        endif()
    endif()
endfunction()

