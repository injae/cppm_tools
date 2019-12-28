macro(cppm_setting)
    cmake_parse_arguments(ARG "NO_MESSAGE" "" "" ${ARGN})
    if(NOT ${CMAKE_PROJECT_NAME} MATCHES ${PROJECT_NAME})
        set(SUB_PROJECT TRUE)
        set(NO_MESSAGE TRUE PARENT_SCOPE)
    else()
        set(SUB_PROJECT FALSE)
    endif()
    if(ARG_NO_MESSAGE)
        set(NO_MESSAGE TRUE)
    endif()

    cppm_set(CPPM_ROOT "${HOME}/.cppm")
    cppm_set(CPPM_SOURCE "${CPPM_ROOT}/cmake")
    cppm_set(CPPM_MODULE "${CPPM_ROOT}/cmake")
    cppm_set(CPPM_SOURCE "${CPPM_ROOT}/src")
    cppm_set(CPPM_CACHE "${CPPM_ROOT}/cache")
    cppm_set(CPPM_VERSION "${CPPM_VERSION}")
    cppm_set(CPPM_CORE "${CPPM_SOURCE}/cppm_tools/${CPPM_VERSION}")
    list(APPEND CMAKE_MODULE_PATH "${CPPM_MODULE}")
    list(APPEND CMAKE_MODULE_PATH "${CPPM_CORE}")

    default_cache(CMAKE_BUILD_TYPE DEBUG STRING)
    string(TOLOWER ${CMAKE_BUILD_TYPE} cppm_build_type) 

    cppm_print("Target: ${PROJECT_NAME} [Type:${cppm_build_type}, Cppm:${CPPM_VERSION}, CMake:${CMAKE_VERSION}]")
    cppm_print("System: ${CMAKE_HOST_SYSTEM_PROCESSOR}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")
    cppm_print("Compiler: ${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
    cppm_print("Generator: ${CMAKE_GENERATOR}")

    _cppm_ccache_setting()
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

    _cppm_find_package_prefix(${CPPM_ROOT}/local)
    cppm_print("cppm_root: ${CPPM_ROOT}")

    _cppm_os_flag()
endmacro()

macro(_cppm_ccache_setting)
    option(USE_CCACHE "use ccache option default is on" ON)
    if(USE_CCACHE)
        find_program(CCACHE_EXE ccache)
        if(CCACHE_EXE)
            set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
            cppm_print("Build Cache: ccache")
        endif()
    endif()
endmacro()

macro(_cppm_find_package_prefix prefix)
    list(APPEND CMAKE_PREFIX_PATH "${prefix}/lib/cmake")
    list(APPEND CMAKE_PREFIX_PATH "${prefix}/lib64/cmake")
    list(APPEND CMAKE_PREFIX_PATH "${prefix}/lib/pkgconfig")
    list(APPEND CMAKE_PREFIX_PATH "${prefix}/lib64/pkgconfig")
endmacro()


macro(_cppm_os_flag)
    if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        add_definitions(-DSYSTEM_LINUX)
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
        add_definitions(-DSYSTEM_DARWIN)
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "AIX")
        add_definitions(-DSYSTEM_AIX)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        add_definitions(-DSYSTEM_WINDOWS)
    endif()
endmacro()
