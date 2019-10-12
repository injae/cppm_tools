macro(_cppm_target_install)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    if(${${name}_target_type} MATCHES "BINARY")
        install(TARGETS ${name} RUNTIME DESTINATION bin)
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
        # project-targets.cmake install part
        install(TARGETS ${name} EXPORT ${CMAKE_PROJECT_NAME}-targets
            ARCHIVE  DESTINATION lib 
            LIBRARY  DESTINATION lib
            RUNTIME  DESTINATION bin
            INCLUDES DESTINATION include
        )
        install(DIRECTORY include/ DESTINATION include)

        install(EXPORT ${CMAKE_PROJECT_NAME}-targets
            FILE ${CMAKE_PROJECT_NAME}-targets.cmake
            NAMESPACE ${CMAKE_PROJECT_NAME}::
            DESTINATION lib/cmake/${CMAKE_PROJECT_NAME}
        )

        #set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
        #export(PACKAGE ${name})
        if(SUB_PROJECT)
            message(STATUS "[cppm] Find Package: ${name}/${PROJECT_VERSION}")
        endif()
        message(STATUS "[cppm] Module : ${PROJECT_NAME}::${name}")
    endif()
endmacro()
