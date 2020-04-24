macro(cppm_setting)
    cmake_parse_arguments(ARG "NO_MESSAGE" "" "" ${ARGN})
    if(NOT CMAKE_PROJECT_NAME MATCHES "${PROJECT_NAME}")
        set(SUB_PROJECT TRUE)
        set(${PROJECT_NAME}_NO_MESSAGE TRUE)
    else()
        set(SUB_PROJECT FALSE)
    endif()
    if(ARG_NO_MESSAGE)
        set(${PROJECT_NAME}_NO_MESSAGE TRUE)
    endif()

    cppm_set(CPPM_ROOT    "${HOME}/.cppm")
    cppm_set(CPPM_PREFIX  "${CPPM_ROOT}")
    cppm_set(CPPM_MODULE  "${CPPM_ROOT}/cmake")
    cppm_set(CPPM_PKGS    "${CPPM_PREFIX}/share")
    cppm_set(CPPM_CACHE   "${CPPM_ROOT}/cache")
    cppm_set(CPPM_VERSION "${CPPM_VERSION}")
    cppm_set(CPPM_CORE    "${CPPM_PKGS}/cppm-tools-${CPPM_VERSION}")
    list(APPEND CMAKE_MODULE_PATH "${CPPM_MODULE}")
    list(APPEND CMAKE_MODULE_PATH "${CPPM_CORE}")
    list(APPEND CMAKE_MODULE_PATH "${CPPM_PKGS}")

    _cppm_os_flag()
    _cppm_generator()
    _cppm_build_type()
    _cppm_rpath()
    _cppkg_define_property()

    cppm_print("Target: ${PROJECT_NAME} [Type:${cppm_build_type}, Cppm:${CPPM_VERSION}, CMake:${CMAKE_VERSION}]")
    cppm_print("System: ${CMAKE_HOST_SYSTEM_PROCESSOR}-${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")
    cppm_print("Compiler: ${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
    cppm_print("Generator: ${CMAKE_GENERATOR}")

    _cppm_ccache()
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)

    _cppm_find_package_prefix(${CPPM_PREFIX})
    cppm_print("cppm_root: ${CPPM_ROOT}")

endmacro()

macro(_cppm_ccache)
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
    list(APPEND CMAKE_PREFIX_PATH "${prefix}")
    list(APPEND CMAKE_PREFIX_PATH "${prefix}/share")
endmacro()

macro(_cppm_rpath) # macos has RPATH bug
    set(CMAKE_SKIP_BUILD_RPATH FALSE)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
    list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
    if("${isSystemDir}" STREQUAL "-1")
        list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    endif("${isSystemDir}" STREQUAL "-1")
endmacro()


macro(_cppm_os_flag)
    if(cppm_target_platform)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
        set(cppm_target_platform uwp)
        set(cppm_target_base_platform windows)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
        set(cppm_target_platform linux)
        set(cppm_target_base_platform unix)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
        set(cppm_target_platform osx)
        set(cppm_target_base_platform unix)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
        set(cppm_target_platform windows)
        set(cppm_target_base_platform windows)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
        set(cppm_target_platform freebsd)
        set(cppm_target_base_platform unix)
    endif()
endmacro()

macro(_cppm_generator)
    if(cppm_generator_type)
    elseif(CMAKE_GENERATOR MATCHES "^Unix Makefiles$")
        set(cppm_generator_type "make")
    elseif(CMAKE_GENERATOR MATCHES "^Ninja$")
        set(cppm_generator_type "ninja")
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio.*$")
        set(cppm_generator_type "visual-studio")
    elseif(CMAKE_GENERATOR MATCHES "^Xcode$")
        set(cppm_generator_type "xcode")
    endif()
endmacro()

macro(_cppm_build_type)
    default_cache(CMAKE_BUILD_TYPE Debug STRING)
    string(TOLOWER ${CMAKE_BUILD_TYPE} cppm_build_type) 
    cppm_set_then(cppm_is_debug "cppm_build_type STREQUAL \"debug\"" ON OFF)
    if(cppm_target_base_platform STREQUAL "unix")
        default_cache(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug STRING)
        default_cache(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release STRING)
    endif()
endmacro()

macro(_cppkg_define_property)
    define_property(TARGET PROPERTY CPPM_DEPENDENCIES INHERITED
        BRIEF_DOCS "Cppm package dependencies list"
        FULL_DOCS  "Cppm package dependencies list"
    )
endmacro()

