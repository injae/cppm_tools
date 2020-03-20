function(cppm_write_target_dependency_file)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    set(Deps "")
    get_target_property(deps ${name}_info CPPM_DEPENDENCIES)
    foreach(dep IN LISTS deps)
        string(CONCAT Deps "find_dependency(${dep})\n")
    endforeach()
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
        "include(CMakeFindDependencyMacro)\n"
        "${Deps}\n"
        "include(\$\{CMAKE_CURRENT_LIST_DIR\}/${PROJECT_NAME}-targets.cmake)\n"
    )
endfunction()

macro(cppm_target_install)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    if(TARGET ${name})
        set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON) # linked shared library project rpath problom fix
        get_target_property(_target_type ${name}_info CPPM_TYPE)
        if(_target_type MATCHES "BINARY")
            install(TARGETS ${name} RUNTIME DESTINATION bin) # $HOME/.cppm/local/share/${name}-${version}
            get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_INSTALL_PREFIX}/../../" ABSOLUTE)
            if(PACKAGE_PREFIX_DIR STREQUAL "${CPPM_PREFIX}")
                add_custom_command(TARGET ${name} POST_BUILD COMMAND ${CMAKE_COMMAND} -E create_symlink "${CMAKE_INSTALL_PREFIX}/bin/$<TARGET_FILE_BASE_NAME:${name}>" "${CPPM_PREFIX}/bin/$<TARGET_FILE_BASE_NAME:${name}>" COMMENT "-- Linking ${CMAKE_INSTALL_PREFIX}/bin -> ${CPPM_PREFIX}/bin/")
                #install(DIRECTORY "${CMAKE_INSTALL_PREFIX}/bin/" DESTINATION ${CPPM_PREFIX}/bin USE_SOURCE_PERMISSIONS)
            endif()
        endif()
        if(_target_type MATCHES "LIBRARY")
            get_target_property(_namespace ${name}_info CPPM_NAMESPACE)
            include(CMakePackageConfigHelpers)
            write_basic_package_version_file(
                ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
                VERSION ${${PROJECT_NAME}_VERSION}
                COMPATIBILITY ExactVersion
            ) 
            install(FILES
                ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
                DESTINATION lib/cmake/${PROJECT_NAME}
            )
            cppm_write_target_dependency_file(${name})

            install(FILES
                ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
                DESTINATION lib/cmake/${PROJECT_NAME}
            )

            # project-targets.cmake install part
            install(TARGETS ${name} EXPORT ${PROJECT_NAME}-targets
                #PUBLIC_HEADER DESTINATION include
                ARCHIVE  DESTINATION lib 
                LIBRARY  DESTINATION lib
                RUNTIME  DESTINATION bin
            )
            install(DIRECTORY include/ DESTINATION include)

            install(EXPORT ${PROJECT_NAME}-targets
                FILE ${PROJECT_NAME}-targets.cmake
                NAMESPACE ${_namespace}::
                DESTINATION lib/cmake/${PROJECT_NAME}
            )

            if(SUB_PROJECT)
                message(STATUS "[cppm] Find Package: ${name}/${PROJECT_VERSION}")
            endif()
            message(STATUS "[cppm] Module : ${_namespace}::${name}")
        endif()
    endif()
endmacro()
