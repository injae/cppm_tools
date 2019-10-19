
macro(cppm_compiler_option)
    cmake_parse_arguments(ARG "DEFAULT" "" "DEBUG;RELEASE" ${ARGN})
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
    cmake_parse_arguments(ARG "DEFAULT" "CLANG;GCC;MSVC" "" ${ARGN})
    if(${ARG_DEFAULT})
        unset(ARG_CLANG)
        unset(ARG_GCC)
        unset(ARG_MSVC)
    endif()

    include(utility/set_cmake_cache)
    if("${cppm_build_type}" STREQUAL "debug")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            add_compiler_option(CMAKE_CXX_FLAGS_DEBUG "-Wall -fPIC -O0 -g")
            add_compiler_option(CMAKE_CXX_FLAGS_DEBUG "${ARG_CLANG}")
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            add_compiler_option(CMAKE_CXX_FLAGS_DEBUG "-Wall -fPIC -O0 -g")
            add_compiler_option(CMAKE_CXX_FLAGS_DEBUG "${ARG_GCC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            add_compiler_option(CMAKE_CXX_FLAGS_DEBUG "/DWIN32 /D_WINDOWS /MP /Zi /Ob0 /Od /EHsc")
            add_compiler_option(CMAKE_CXX_FLAGS_DEBUG "${ARG_MSVC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        endif()
        cppm_print("Compiler Option: ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    endif()
endmacro()

macro(_cppm_compiler_release_option)
    cmake_parse_arguments(ARG "DEFAULT"  "CLANG;GCC;MSVC" "" ${ARGN})
    if(${ARG_DEFAULT})
        unset(ARG_CLANG)
        unset(ARG_GCC)
        unset(ARG_MSVC)
    endif()

    include(utility/set_cmake_cache)
    if("${cppm_build_type}" STREQUAL "release")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            add_compiler_option(CMAKE_CXX_FLAGS_RELEASE "-fPIC -O3 -DNDEBUG")
            add_compiler_option(CMAKE_CXX_FLAGS_RELEASE "${ARG_CLANG}")
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            add_compiler_option(CMAKE_CXX_FLAGS_RELEASE "-fPIC -O3 -DNDEBUG")
            add_compiler_option(CMAKE_CXX_FLAGS_RELEASE "${ARG_GCC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            add_compiler_option(CMAKE_CXX_FLAGS_RELEASE "/DWIN32 /D_WINDOWS /MP /O2 /EHsc")
            add_compiler_option(CMAKE_CXX_FLAGS_RELEASE "${ARG_MSVC}")
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        endif()
        cppm_print("Compiler Option: ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
    endif()
endmacro()
