function(cppm_write_target_dependency_file)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    set(Deps "")
    foreach(dep IN LISTS _D_${name})
        string(CONCAT Deps "find_dependency(${dep})\n")
    endforeach()
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}-config.cmake
        "include(CMakeFindDependencyMacro)\n"
        "${Deps}\n"
        "include(\$\{CMAKE_CURRENT_LIST_DIR\}/${CMAKE_PROJECT_NAME}-targets.cmake)\n"
    )
endfunction()

macro(cppm_target_install)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    if(${_O_${name}})
        if(${${name}_target_type} MATCHES "BINARY")
            install(TARGETS ${name} RUNTIME DESTINATION bin)
                                                      # $HOME/.cppm/local/share/${name}/${version}
            get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_INSTALL_PREFIX}/../../../" ABSOLUTE)
            if(PACKAGE_PREFIX_DIR STREQUAL "${CPPM_PREFIX}")
                install(DIRECTORY "${CMAKE_INSTALL_PREFIX}/bin/" DESTINATION ${CPPM_PREFIX}/bin)
            endif()
        endif()
        if(${${name}_target_type} MATCHES "LIBRARY")
            # project-config-version.cmake install part
            include(CMakePackageConfigHelpers)
            write_basic_package_version_file(
            ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}-config-version.cmake
            VERSION ${${CMAKE_PROJECT_NAME}_VERSION}
            COMPATIBILITY ExactVersion
            ) 
            install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}-config-version.cmake
            DESTINATION lib/cmake/${CMAKE_PROJECT_NAME}
            )
            cppm_write_target_dependency_file(${name})

            install(FILES
                ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}-config.cmake
                DESTINATION lib/cmake/${CMAKE_PROJECT_NAME}
            )

            # project-targets.cmake install part
            install(TARGETS ${name} EXPORT ${CMAKE_PROJECT_NAME}-targets
                ARCHIVE  DESTINATION lib 
                LIBRARY  DESTINATION lib
                RUNTIME  DESTINATION bin
            )
            install(DIRECTORY include/ DESTINATION include)

            install(EXPORT ${CMAKE_PROJECT_NAME}-targets
                FILE ${CMAKE_PROJECT_NAME}-targets.cmake
                NAMESPACE ${CMAKE_PROJECT_NAME}::
                DESTINATION lib/cmake/${CMAKE_PROJECT_NAME}
            )

            if(SUB_PROJECT)
                message(STATUS "[cppm] Find Package: ${name}/${PROJECT_VERSION}")
            endif()
            message(STATUS "[cppm] Module : ${CMAKE_PROJECT_NAME}::${name}")
        endif()
    endif()
endmacro()
