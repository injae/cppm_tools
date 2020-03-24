function(add_cppkg_info name)
    cmake_parse_arguments(ARG "" "VERSION" "MODULE" ${ARGN})
    if(TARGET ${name}_info)
    else()
        add_custom_target(${name}_info COMMENT "Cppkg Info Target")
    endif()

    set_target_properties(${name}_info PROPERTIES
        CPPM_MODULE "${ARG_MODULE}"
        CPPM_VERSION ${ARG_VERSION}
        CPPM_DESCRIPTION "${name}/${ARG_VERSION}"
    )
endfunction()

function(find_cppkg)
    cmake_parse_arguments(ARG "HUNTER" "" "MODULE;COMPONENTS;LOADPATH" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(GET ARG_UNPARSED_ARGUMENTS 1 version)
    set(version_ ${version})
    if(version STREQUAL "latest")
      set(version "")
    endif()

    if(version STREQUAL "git")
      set(version "")
      set(_is_not_git "")
    else()
      set(_is_not_git "EXACT")
    endif()

    if(ARG_HUNTER) 
        if(DEFINED ARG_COMPONENTS)
          hunter_add_package(${name} COMPONENTS ${ARG_COMPONENTS})
        else() 
          hunter_add_package(${name})
        endif()
        cppm_print("Load Package ${name} from Hunter")
    endif()

    set(_cppkg "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/${name}.cmake.in") 
    if(EXISTS ${_cppkg})
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
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/dep.cmake)
            include(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/dep.cmake)
        endif()
        message("<==[[${name}]]")
    endif()
    if(DEFINED ARG_LOADPATH)
        add_cppkg_info(${name}
             MODULE  "${ARG_MODULE}"
             VERSION "${version_}")
        set_target_properties(${name}_info PROPERTIES CPPM_LOADPATH "${ARG_LOADPATH}")
        if(NOT ARG_LOADPATH MATCHES "^\.\./.*$") # out of tree dependency(workspace) use this option
            message("==>[[${name}]]")
            add_subdirectory(${ARG_LOADPATH})
            message("<==[[${name}]]")
        else()
            cppkg_print("Load Workspace ${name}/${version_} from ${ARG_LOADPATH}")
        endif()
    else()
        if(DEFINED ARG_COMPONENTS)
             find_package(${name} ${version} COMPONENTS ${ARG_COMPONENTS} ${_is_not_git} QUIET)
        else()
             find_package(${name} ${version} ${_is_not_git} QUIET)
        endif()

        if(${${name}_FOUND})
            cppkg_print("Load Package: ${name}/${${name}_VERSION} from Cppkg")
            add_cppkg_info(${name}
                MODULE  "${ARG_MODULE}"
                VERSION "${${name}_VERSION}")
        else()
            cppm_error_print("Can't find Package ${name}/${${name}_VERSION}")
        endif()
    endif()
endfunction()
