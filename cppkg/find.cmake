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
        cppm_print("Load ${name} hunter file")
        if(DEFINED ARG_COMPONENTS)
          hunter_add_package(${name} COMPONENTS ${ARG_COMPONENTS})
        else() 
          hunter_add_package(${name})
        endif()
    endif()

    set(_cppkg "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/${name}.cmake.in") 
    if(EXISTS ${_cppkg})
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
    endif()
    if(DEFINED ARG_LOADPATH)
         cppkg_print("Load ${name} from ${ARG_LOADPATH}")
         add_cppkg_info(${name}
             MODULE  "${ARG_MODULE}"
             VERSION "${version_}")
        if(NOT ARG_LOADPATH MATCHES "^\.\./.*$") # out of tree dependency(workspace) use this option
            add_subdirectory(${ARG_LOADPATH})
        endif()
    else()
        if(DEFINED ARG_COMPONENTS)
             find_package(${name} ${version} COMPONENTS ${ARG_COMPONENTS} ${_is_not_git} QUIET)
        else()
             find_package(${name} ${version} ${_is_not_git} QUIET)
        endif()

        if("${${name}_FOUND}")
            cppkg_print("Find Package: ${name}/${${name}_VERSION}")
            add_cppkg_info(${name}
                MODULE  "${ARG_MODULE}"
                VERSION "${${name}_VERSION}")
        endif()
    endif()
endfunction()
