function(_cppm_target_define)
    cmake_parse_arguments(ARG "BINARY;STATIC;SHARED;INTERFACE" "" "SOURCES" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)

    if(${name} MATCHES ${CMAKE_PROJECT_NAME})
        set(lib_include_dir "include")
        set(lib_source_dir  "src")
    else()
        set(lib_include_dir "include/${CMAKE_PROJECT_NAME}/${name}")
        set(lib_source_dir  "src/${name}")
    endif()

    if(${ARG_BINARY})
        add_executable(${name} "")
        set(${name}_target_type "BINARY" PARENT_SCOPE)
        target_include_directories(${name}
            PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
            PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
        )
    elseif(${ARG_STATIC} OR ${ARG_SHARED})
        set(${name}_target_type "LIBRARY" PARENT_SCOPE)
        if(${ARG_STATIC})
            add_library(${name} STATIC "")
        elseif(${ARG_SHARED})
            add_library(${name} SHARED "")
        endif()
        add_library(${PROJECT_NAME}::${name} ALIAS ${name})
        set_target_properties(${name} PROPERTIES LINKER_LANGUAGE CXX)
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

    if(DEFINED ARG_SOURCES)
        target_sources(${name} PRIVATE ${ARG_SOURCES})
    endif()
endfunction()