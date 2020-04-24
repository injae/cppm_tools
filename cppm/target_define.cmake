function(cppm_target_define)
    cmake_parse_arguments(ARG "BINARY;STATIC;SHARED;INTERFACE;EXCLUDE" "OPTIONAL;NAMESPACE;PUBLIC_HEADER;PRIVATE_HEADER" "SOURCES" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    cppm_set_then(_public_header  "include"                             "ARG_PUBLIC_HEADER"  "${ARG_PUBLIC_HEADER}")
    cppm_set_then(_private_header "src"                                 "ARG_PRIVATE_HEADER" "${ARG_PRIVATE_HEADER}")
    cppm_set_then(_namespace      "${CMAKE_PROJECT_NAME}"               "ARG_NAMESPACE"      "${ARG_NAMESPACE}")
    cppm_set_then(_optional       "${CMAKE_PROJECT_NAME}_${name}_BUILD" "ARG_OPTIONAL"       "${ARG_OPTIONAL}")
    cmake_dependent_option("${_optional}" "build with ${name}" ON "NOT ARG_EXCLUDE" OFF)

    if(${${_optional}})
        if(TARGET ${name}_info)
        else()
            add_custom_target(${name}_info COMMENT "Cppkg Info Target")
        endif()
        if(ARG_BINARY)
            add_executable(${name} "")
            set_target_properties(${name}_info PROPERTIES CPPM_TYPE "BINARY")
            target_include_directories(${name}
                PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/${_public_header}
                PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${_private_header}
            )
        elseif(ARG_STATIC OR ARG_SHARED)
            if(ARG_STATIC)
                add_library(${name} STATIC "")
            elseif(ARG_SHARED)
                add_library(${name} SHARED "")
            endif()
            add_library(${_namespace}::${name} ALIAS ${name})
            set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)
            set_target_properties(${name}_info PROPERTIES CPPM_NAMESPACE "${_namespace}" CPPM_TYPE "LIBRARY")
            set_target_properties(${name}_info PROPERTIES CPPM_MODULE "${name}"
                                                          CPPM_DESCRIPTION "${name}/${${PROJECT_NAME}_VERSION}")
            set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
            target_include_directories(${name}
                PUBLIC
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${_public_header}>
                    $<INSTALL_INTERFACE:include>
                PRIVATE
                    ${CMAKE_CURRENT_SOURCE_DIR}/${_private_header}
            )
        elseif(ARG_INTERFACE)
            add_library(${name} INTERFACE)
            add_library(${_namespace}::${name} ALIAS ${name})
            set_target_properties(${name}_info PROPERTIES CPPM_NAMESPACE "${_namespace}" CPPM_TYPE "LIBRARY")
            set_target_properties(${name}_info PROPERTIES CPPM_MODULE "${name}"
                                                          CPPM_DESCRIPTION "${name}/${${PROJECT_NAME}_VERSION}")
            target_include_directories(${name}
                INTERFACE
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${_public_header}>
                    $<INSTALL_INTERFACE:include>
            )
        endif()
        if(SUB_PROJECT)
            include_directories(${_public_header})
            get_target_property(_load_path ${name}_info CPPM_LOADPATH)
            cppkg_print("Load Workspace: ${name}/${PROJECT_VERSION} from ${_load_path}")
        endif()
        target_compile_features(${name} INTERFACE "cxx_std_${cxx_standard}")
        if(DEFINED ARG_SOURCES)
            target_sources(${name} PRIVATE ${ARG_SOURCES})
        endif()
    endif()
endfunction()

function(cppm_with_unit_test)
    string(TOUPPER ${CMAKE_PROJECT_NAME} upper_name) 
    cmake_dependent_option("${upper_name}_BUILD_TESTING" "${CMAKE_PROJECT_NAME} build test"
        ON "CMAKE_BUILD_TYPE STREQUAL Debug" OFF)
endfunction()

function(cppm_with_examples)
    string(TOUPPER ${CMAKE_PROJECT_NAME} upper_name) 
    option(${upper_name}_BUILD_EXAMPLES "${CMAKE_PROJECT_NAME} build examples" OFF)
endfunction()
