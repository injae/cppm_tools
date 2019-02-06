function(_find_cppkg)
    set(options HUNTER)
    set(oneValueArg)
    set(multiValueArgs COMPONENTS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 name)
    list(GET ARG_UNPARSED_ARGUMENTS 1 version)
    set(version_ ${version})
    if(version STREQUAL "lastest")
      set(version "")
    endif()

    if(ARG_HUNTER) 
        message(STATUS "[cppm] Load ${name} hunter file")
        if(DEFINED ARG_COMPONENTS)
          hunter_add_package(${name} COMPONENTS ${ARG_COMPONENTS})
        else()
          hunter_add_package(${name})
        endif()
    endif()

    set(new_cppkg "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/${name}.cmake.in") 

    if(EXISTS ${new_cppkg})
        configure_file(thirdparty/${name}/${version_}/${name}.cmake.in
                       ${CMAKE_BINARY_DIR}/thirdparty/${name}/${version_}/CMakeLists.txt)
        execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" 
                                                 "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}" .
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/thirdparty/${name}/${version_})
        execute_process(COMMAND cmake  --build .
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/thirdparty/${name}/${version_})
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/dep.cmake)
            include(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/${name}/${version_}/dep.cmake)
        endif()
    endif()

    if(DEFINED ARG_COMPONENTS)
        find_package(${name} ${version} COMPONENTS ${ARG_COMPONENTS} QUIET)
    else()
        find_package(${name} ${version} QUIET)
    endif()

   if("${${name}_FOUND}")
     message(STATUS "[cppm] Find Package: ${name}/${${name}_VERSION}")
   endif()

endfunction()
