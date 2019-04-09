macro(_cppm_compiler_option)
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

    set(DEF_CLANG_OPT -Wall -fPIC -O0 -g)
    set(DEF_GCC_OPT   -Wall -fPIC -O0 -g)
    set(DEF_MSVC_OPT  /MP /MDd /Zi /Ob0 /Od)

    if(NOT DEFINED ARG_CLANG)
        set(ARG_CLANG -std=c++17)
    endif()
    if(NOT DEFINED ARG_GCC)
        set(ARG_GCC   -std=c++17)
    endif()
    if(NOT DEFINED ARG_MSVC)
        set(ARG_MSVC  /std:c++17)
    endif()

    if(NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        message("Build Type: Debug")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            add_compile_options(${DEF_CLANG_OPT} ${ARG_CLANG})
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            add_compile_options(${DEF_GCC_OPT}   ${ARG_GCC})
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            add_compile_options(${DEF_MSVC_OPT}  ${ARG_MSVC})
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        endif()
    endif()
endmacro()

macro(_cppm_compiler_release_option)
    cmake_parse_arguments(ARG "DEFAULT" "CLANG;GCC;MSVC" "" ${ARGN})
    if(${ARG_DEFAULT})
        unset(ARG_CLANG)
        unset(ARG_GCC)
        unset(ARG_MSVC)
    endif()

    set(DEF_CLANG_OPT -fPIC -O3 -DNDEBUG)
    set(DEF_GCC_OPT   -fPIC -O3 -DNDEBUG)
    set(DEF_MSVC_OPT  /MP /MD /Zi /O2 /DNDEBUG)

    if(NOT DEFINED ARG_CLANG)
        set(ARG_CLANG -std=c++17)
    endif()
    if(NOT DEFINED ARG_GCC)
        set(ARG_GCC   -std=c++17)
    endif()
    if(NOT DEFINED ARG_MSVC)
        set(ARG_MSVC  /std:c++17)
    endif()

    if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        message("Build Type: ${CMAKE_BUILD_TYPE}")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            add_compile_options(${DEF_CLANG_OPT} ${ARG_CLANG})
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            add_compile_options(${DEF_GCC_OPT}   ${ARG_GCC})
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            add_compile_options(${DEF_MSVC_OPT}  ${ARG_MSVC})
        elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        endif()
    endif()
endmacro()
