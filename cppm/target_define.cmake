macro(cppm_target_define)
    cmake_parse_arguments(ARG "BINARY;STATIC;SHARED;INTERFACE;EXCLUDE" "OPTIONAL;NAMESPACE" "SOURCES" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    set(lib_include_dir "include")
    set(lib_source_dir  "src")

    if(ARG_OPTIONAL)
        set(_O_${name} ${ARG_OPTIONAL})
    else()
        set(_O_${name} ${CMAKE_PROJECT_NAME}_${name})
    endif()
    if(ARG_EXCLUDE)
        option(${_O_${name}} "Build with ${name}" OFF)
    else()
        option(${_O_${name}} "Build with ${name}" ON)
    endif()

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
                PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
                PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
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
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${lib_include_dir}>
                    $<INSTALL_INTERFACE:include>
                PRIVATE
                    ${CMAKE_CURRENT_SOURCE_DIR}/${lib_source_dir}
            )
        elseif(ARG_INTERFACE)
            add_library(${name} INTERFACE)
            add_library(${_namespace}::${name} ALIAS ${name})
            set_target_properties(${name}_info PROPERTIES CPPM_NAMESPACE "${_namespace}" CPPM_TYPE "LIBRARY")
            set_target_properties(${name}_info PROPERTIES CPPM_MODULE "${name}"
                                                          CPPM_DESCRIPTION "${name}/${${PROJECT_NAME}_VERSION}")
            target_include_directories(${name}
                INTERFACE
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${lib_include_dir}>
                    $<INSTALL_INTERFACE:include>
            )
        endif()
        if(SUB_PROJECT)
            include_directories(${lib_include_dir})
            get_target_property(_load_path ${name}_info CPPM_LOADPATH)
            cppkg_print("Load Workspace: ${name}/${PROJECT_VERSION} from ${_load_path}")
        endif()
        target_compile_features(${name} INTERFACE "cxx_std_${cxx_standard}")
        if(DEFINED ARG_SOURCES)
            target_sources(${name} PRIVATE ${ARG_SOURCES})
        endif()
    endif()
endmacro()
