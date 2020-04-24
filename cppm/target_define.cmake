macro(cppm_target_define)
    cmake_parse_arguments(ARG "BINARY;STATIC;SHARED;INTERFACE;EXCLUDE" "OPTIONAL;NAMESPACE;PUBLIC_HEADER;PRIVATE_HEADER" "SOURCES" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    #cppm_set_if_else(_public_header  "ARG_PUBLIC_HEADER"  "${ARG_PUBLIC_HEADER}"  "include")
    #cppm_set_if_else(_private_header "ARG_PRIVATE_HEADER" "${ARG_PRIVATE_HEADER}" "src")

    if(ARG_PUBLIC_HEADER)
        set(_public_header ${ARG_PUBLIC_HEADER})
    else()
        set(_public_header "include")
    endif()

    if(ARG_PRIVATE_HEADER)
        set(_private_header ${ARG_PRIVATE_HEADER})
    else()          
        set(_private_header "src")
    endif()

    if(ARG_OPTIONAL)
        set(_O_${name} ${ARG_OPTIONAL})
    else()
        set(_O_${name} ${CMAKE_PROJECT_NAME}_${name})
    endif()

    cmake_dependent_option(${_O_${name}} "Build with ${name}" ON "ARG_EXCLUDE" OFF)

    if(ARG_NAMESPACE)
        set(_namespace ${ARG_NAMESPACE})
    else()
        set(_namespace ${CMAKE_PROJECT_NAME})
    endif()

    if(${_O_${name}})
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
endmacro()
