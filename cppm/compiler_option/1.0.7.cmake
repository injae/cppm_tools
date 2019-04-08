macro(_cppm_compiler_option)
    cmake_parse_arguments(ARG "DEFAULT" "" "DEBUG RELEASE" ${ARGN})

    if(${ARG_DEFAULT})
        _cppm_compiler_debug_option(DEFAULT)
        _cppm_compiler_release_option(DEFAULT)
    else()
        if(DEFINED ARG_DEBUG)
            _cppm_compiler_debug_option(${ARG_DEBUG})
        else()
            _cppm_compiler_debug_option(DEFAULT)
        endif()

        if(DEFINED ARG_RELEASE)
            _cppm_compiler_release_option(${ARG_RELEAGE})
        else()
            _cppm_compiler_release_option(DEFAULT)
        endif()
    endif()
endmacro()

macro(_cppm_compiler_debug_option)
    cmake_parse_arguments(ARG "DEFAULT" "" "CLANG GCC MSVC" ${ARGN})

    if(${ARG_DEFAULT})
        unset(ARG_CLANG)
        unset(ARG_GCC)
        unset(ARG_MSVC)
    endif()

    message("${ARG_CLANG}")
    message("${ARG_GCC}")
    message("${ARG_MSVC}")

    if(NOT DEFINED ${ARG_CLANG})
        set(ARG_CLANG "-Wall -fPIC -O0 -g -std=c++14")
    endif()
    if(NOT DEFINED ${ARG_GCC})
        set(ARG_GCC  "-Wall -fPIC -O0 -g -std=c++14")
    endif()
    if(NOT DEFINED ${ARG_MSVC})
        set(ARG_MSVC "/std:c++14 /MP")
    endif()

    if(NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARG_CLANG}")
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARG_GCC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARG_MSVC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ")
        endif()
    endif()
endmacro()

macro(_cppm_compiler_release_option)
    cmake_parse_arguments(ARG "DEFAULT" "" "CLANG GCC MSVC" ${ARGN})

    if(${ARG_DEFAULT})
        unset(ARG_CLANG)
        unset(ARG_GCC)
        unset(ARG_MSVC)
    endif()

    message("${ARG_CLANG}")
    message("${ARG_GCC}")
    message("${ARG_MSVC}")

    if(NOT DEFINED ${ARG_CLANG})
        set(ARG_CLANG "-fPIC -O0 -std=c++14")
    endif()
    if(NOT DEFINED ${ARG_GCC})
        set(ARG_GCC  "-fPIC -O0 -std=c++14")
    endif()
    if(NOT DEFINED ${ARG_MSVC})
        set(ARG_MSVC "/std:c++14 /MP")
    endif()

    if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARG_CLANG}")
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARG_GCC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ARG_MSVC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ")
        endif()
    endif()
endmacro()
