macro(cppm_target_define)
    cmake_parse_arguments(ARG "BINARY;STATIC;SHARED;INTERFACE;EXCLUDE" "OPTIONAL" "SOURCES" ${ARGN})
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

    if(${_O_${name}})
        if(${ARG_BINARY})
            add_executable(${name} "")
            set(${name}_target_type "BINARY")
            target_include_directories(${name}
                PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
                PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
            )
        elseif(${ARG_STATIC} OR ${ARG_SHARED})
            if(${ARG_STATIC})
                add_library(${name} STATIC "")
            elseif(${ARG_SHARED})
                add_library(${name} SHARED "")
            endif()
            set(${name}_target_type "LIBRARY")
            add_library(${PROJECT_NAME}::${name} ALIAS ${name})
            set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)
            set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
            target_include_directories(${name}
                PUBLIC
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${lib_include_dir}>
                    $<INSTALL_INTERFACE:include>
                PRIVATE
                    ${CMAKE_CURRENT_SOURCE_DIR}/${lib_source_dir}
            )
        elseif(${ARG_INTERFACE})
            set(${name}_target_type "LIBRARY")
            add_library(${name} INTERFACE)
            add_library(${PROJECT_NAME}::${name} ALIAS ${name})
            target_include_directories(${name}
                INTERFACE
                    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${lib_include_dir}>
                    $<INSTALL_INTERFACE:include>
            )
        endif()
        if(SUB_PROJECT)
            include_directories(${lib_include_dir})
        endif()
        target_compile_features(${name} INTERFACE "cxx_std_${cxx_standard}")
        if(DEFINED ARG_SOURCES)
            target_sources(${name} PRIVATE ${ARG_SOURCES})
        endif()
    endif()
endmacro()
