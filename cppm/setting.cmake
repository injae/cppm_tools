macro(cppm_setting)
    cmake_parse_arguments(ARG "NO_MESSAGE;UNITY_BUILD" "" "" ${ARGN})
    include(CMakeDependentOption)

    if(NOT CPPM_LOAD)
        include(${CMAKE_TOOLCHAIN_FILE})
        message("prefix: ${CMAKE_PREFIX_PATH}")
    endif()

    default_cache(cppm_root_is_cppm_project FALSE BOOL)
    if(NOT CMAKE_PROJECT_NAME MATCHES "${PROJECT_NAME}")
        set(SUB_PROJECT TRUE)
        set(${PROJECT_NAME}_NO_MESSAGE TRUE)
    else()
        set(SUB_PROJECT FALSE)
        cppm_set(cppm_root_is_cppm_project TRUE)
    endif()
    if(ARG_NO_MESSAGE)
        set(${PROJECT_NAME}_NO_MESSAGE TRUE)
    endif()

    cppkg_print("Toolchains: ${CMAKE_TOOLCHAIN_FILE}")
    if(NOT ${PROJECT_NAME}_NO_MESSAGE)
        cppm_print("Tools: CMake-${CMAKE_VERSION}, cppm-tools-${CPPM_TOOLS_VERSION}")
        cppm_print("Target: ${PROJECT_NAME}-${PROJECT_VERSION}-${cppm_build_type}")
        cppm_print("System: ${cppm_target_triplet}")
        cppm_print("Compiler: ${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}")
        cppm_print("Generator: ${CMAKE_GENERATOR}")
        cppm_print("Toolchains: ${CMAKE_TOOLCHAIN_FILE}")
        cppm_print("Install: ${CMAKE_INSTALL_PREFIX}")
    endif()

    if(cppm_detect_vcpkg)
        cppm_print("Detect Vcpkg: ${vcpkg_path}")
    endif()
    if(ARG_UNITY_BUILD)
        set(CMAKE_UNITY_BUILD TRUE)
        cppm_print("Unity Build")
    endif()
    cppm_set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    cppm_set(CMAKE_FIND_PACKAGE_SORT_ORDER NATURAL)
    cppm_print("cppm_root: ${CPPM_ROOT}")
endmacro()

macro(_cppm_set_prefix)
    _cppm_build_type()
    if(CMAKE_PROJECT_NAME STREQUAL "${PROJECT_NAME}" OR (NOT cppm_root_is_cppm_project)) # is root project, not sub project
        list(REMOVE_ITEM CMAKE_PREFIX_PATH    "${CPPM_PKGS}" "${CPPM_PKGS}/debug" "${CPPM_ROOT}")
        list(REMOVE_ITEM CMAKE_LIBRARY_PATH   "${CPPM_PKGS}" "${CPPM_PKGS}/debug" "${CPPM_ROOT}")
        list(REMOVE_ITEM CMAKE_FIND_ROOT_PATH "${CPPM_PKGS}" "${CPPM_PKGS}/debug" "${CPPM_ROOT}")

        if(cppm_build_type STREQUAL "release" OR (NOT cppm_generator_type STREQUAL "visual"))
            list(APPEND CMAKE_PREFIX_PATH    "${CPPM_PKGS}" "${CPPM_ROOT}")
            list(APPEND CMAKE_LIBRARY_PATH   "${CPPM_PKGS}" "${CPPM_ROOT}")
            list(APPEND CMAKE_FIND_ROOT_PATH "${CPPM_PKGS}" "${CPPM_ROOT}")
            set(CPPM_INSTALL_PREFIX "${CPPM_PKGS}")
        else()
            list(APPEND CMAKE_PREFIX_PATH    "${CPPM_PKGS}/debug" "${CPPM_ROOT}")
            list(APPEND CMAKE_LIBRARY_PATH   "${CPPM_PKGS}/debug" "${CPPM_ROOT}")
            list(APPEND CMAKE_FIND_ROOT_PATH "${CPPM_PKGS}/debug" "${CPPM_ROOT}")
            set(CPPM_INSTALL_PREFIX "${CPPM_PKGS}/debug")
        endif()

        cppm_set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
        cppm_set(CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
        cppm_set(CMAKE_LIBRARY_PATH "${CMAKE_LIBRARY_PATH}")

        if(USE_CPPM_PATH)
            if("${CMAKE_PROJECT_VERSION}" STREQUAL "" OR (CPPKG_GIT_VERSION))
                cppm_set(CMAKE_INSTALL_PREFIX "${CPPM_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}")
            else()
                cppm_set(CMAKE_INSTALL_PREFIX "${CPPM_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}")
            endif()
        endif()
    endif()
endmacro()

macro(_cppm_ccache)
    option(USE_CCACHE "use ccache option default is on" ON)
    if(USE_CCACHE)
        include(${CPPM_TOOL}/cppkg/search_cppkg)
        search_cppkg(ccache bin)
        if(ccache_found)
            cppm_set(CMAKE_CXX_COMPILER_LAUNCHER ${ccache_path})
        endif()
    endif()
endmacro()

macro(_cppm_rpath) # macos has RPATH bug
    cppm_set(CMAKE_SKIP_BUILD_RPATH FALSE)
    cppm_set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
    list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    cppm_set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
    if("${isSystemDir}" STREQUAL "-1")
        list(APPEND CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
    endif("${isSystemDir}" STREQUAL "-1")
    cppm_set(${CMAKE_INSTALL_RPATH} "${CMAKE_INSTALL_RPATH}")
endmacro()

# from vcpkg https://github.com/microsoft/vcpkg/blob/master/scripts/buildsystems/vcpkg.cmake
macro(_cppm_arch_flag)
if(cppm_target_arch)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
    set(cppm_target_arch x86)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
    set(cppm_target_arch x64)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
    set(cppm_target_arch arm)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
    set(cppm_target_arch arm64)
else()
    if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 Win64$")
        set(cppm_target_arch x64)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 ARM$")
        set(cppm_target_arch arm)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015$")
        set(cppm_target_arch x86)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 Win64$")
        set(cppm_target_arch x64)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 ARM$")
        set(cppm_target_arch arm)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017$")
        set(cppm_target_arch x86)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 16 2019$")
        set(cppm_target_arch x64)
    else()
        find_program(cl_path cl)
        if(cl_path MATCHES "amd64/cl.exe$" OR cl_path MATCHES "x64/cl.exe$")
            set(cppm_target_arch x64)
        elseif(cl_path MATCHES "arm/cl.exe$")
            set(cppm_target_arch arm)
        elseif(cl_path MATCHES "arm64/cl.exe$")
            set(cppm_target_arch arm64)
        elseif(cl_path MATCHES "bin/cl.exe$" OR cl_path MATCHES "x86/cl.exe$")
            set(cppm_target_arch x86)
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin" AND DEFINED CMAKE_SYSTEM_NAME AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            list(LENGTH CMAKE_OSX_ARCHITECTURES arch_count)
            if(arch_count EQUAL 0)
                cppm_warning_print("Unable to determine target architecture. "
                                   "Consider providing a value for the CMAKE_OSX_ARCHITECTURES cache variable. ")
            else()
                if(arch_count GREATER 1)
                    cppm_warning_print("Detected more than one target architecture. Using the first one.")
                endif()
                list(GET CMAKE_OSX_ARCHITECTURES 0 target_arch)
                if(target_arch STREQUAL arm64)
                    set(cppm_target_arch arm64)
                elseif(target_arch STREQUAL arm64s)
                    set(cppm_target_arch arm64s)
                elseif(target_arch STREQUAL armv7s)
                    set(cppm_target_arch armv7s)
                elseif(target_arch STREQUAL armv7)
                    set(cppm_target_arch arm)
                elseif(target_arch STREQUAL x86_64)
                    set(cppm_target_arch x64)
                elseif(target_arch STREQUAL i386)
                    set(cppm_target_arch x86)
                else()
                    cppm_warning_print("Unable to determine target architecture")
                endif()
            endif()
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
            set(cppm_target_arch x64)
        else()
            cppm_warning_print("Unable to determine target architecture")
        endif()
        cppm_set(cppm_target_arch ${cppm_target_arch})
    endif()
endif()

endmacro()

# from vcpkg https://github.com/microsoft/vcpkg/blob/master/scripts/buildsystems/vcpkg.cmake
macro(_cppm_os_flag)
    if(cppm_target_platform)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
        cppm_set(cppm_target_platform uwp)
        cppm_set(cppm_target_base_platform windows)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
        cppm_set(cppm_target_platform linux)
        cppm_set(cppm_target_base_platform unix)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
        cppm_set(cppm_target_platform osx)
        cppm_set(cppm_target_base_platform unix)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
        cppm_set(cppm_target_platform windows)
        cppm_set(cppm_target_base_platform windows)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
        cppm_set(cppm_target_platform freebsd)
        cppm_set(cppm_target_base_platform unix)
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Android" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Android"))
        cppm_set(cppm_target_platform android)
        cppm_set(cppm_target_base_platform unix)
    endif()
endmacro()

macro(_cppm_generator)
    if(cppm_generator_type)
    elseif(CMAKE_GENERATOR MATCHES "^Unix Makefiles$")
        cppm_set(cppm_generator_type "make")
    elseif(CMAKE_GENERATOR MATCHES "^Ninja$")
        cppm_set(cppm_generator_type "ninja")
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio.*$")
        cppm_set(cppm_generator_type "visual")
    elseif(CMAKE_GENERATOR MATCHES "^Xcode$")
        cppm_set(cppm_generator_type "xcode")
    endif()
endmacro()

macro(_cppm_build_type)
    default_cache(CMAKE_BUILD_TYPE Debug STRING)
    string(TOLOWER ${CMAKE_BUILD_TYPE} lower_build_type) 
    set_cache_check(cppm_build_type "${lower_build_type}" STRING)
    if(_is_same)
        set_cache(cppm_build_type_change FALSE BOOL)
    else()
        set_cache(cppm_build_type_change TRUE BOOL)
    endif()

    if(cppm_build_type STREQUAL "debug")
        set(cppm_is_debug ON)
    else()
        set(cppm_is_debug OFF)
    endif()

    if(cppm_target_base_platform STREQUAL "unix")
        default_cache(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug STRING)
        default_cache(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release STRING)
        default_cache(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug STRING)
        default_cache(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release STRING)
        default_cache(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug STRING)
        default_cache(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release STRING)
    endif()
endmacro()

macro(_cppm_compiler_type)
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        if("x${CMAKE_CXX_SIMULATE_ID}" STREQUAL "xMSVC")
            cppm_set(cppm_compiler_type "clang")
            cppm_set(cppm_compiler_name "clang_cl")
        else()
            cppm_set(cppm_compiler_type "clang")
            cppm_set(cppm_compiler_name "clang")
        endif()
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        cppm_set(cppm_compiler_type "clang")
        cppm_set(cppm_compiler_name "apple_clang")
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        cppm_set(cppm_compiler_type "gnu")
        cppm_set(cppm_compiler_name "gcc")
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        cppm_set(cppm_compiler_type "msvc")
        cppm_set(cppm_compiler_name "cl")
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
        cppm_set(cppm_compiler_type "intel")
        cppm_set(cppm_compiler_name "intel")
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "NVIDIA")
        cppm_set(cppm_compiler_type "cuda")
        cppm_set(cppm_compiler_name "nvidia")
    else()
        cppm_set(cppm_compiler_type "unknown")
        cppm_set(cppm_compiler_name "unknown")
    endif()
endmacro()

macro(_cppkg_define_property)
    define_property(TARGET PROPERTY CPPM_DEPENDENCIES INHERITED
        BRIEF_DOCS "Cppm package dependencies list"
        FULL_DOCS  "Cppm package dependencies list"
    )
endmacro()

# arch platform generater(optional)
function(triplet_check triplet)
    string(REPLACE "-" ";" atoms "${triplet}")
    list(LENGTH atoms atoms_l)
    if(atoms_l EQUAL 3)
        list(GET atoms 0 arch)
        list(GET atoms 1 platform)
        list(GET atoms 2 compiler)
        set(has_compiler TRUE)
    elseif(atoms_l EQUAL 1)
        set(arch "all")
        list(GET atoms 0 platform)
    else()
        list(GET atoms 0 arch)
        list(GET atoms 1 platform)
    endif()

    if("${arch}" STREQUAL "${cppm_target_arch}" OR ("${arch}" STREQUAL "all"))
    else()
        set(_result FALSE PARENT_SCOPE)
        return()
    endif()

    if("${platform}" STREQUAL "${cppm_target_platform}" OR ("${platform}" STREQUAL "${cppm_target_base_platform}"))
        if(has_compiler)
            if("${compiler}" STREQUAL "${cppm_compiler_type}" OR ("${compiler}" STREQUAL "${cppm_compiler_name}"))
                set(_result TRUE PARENT_SCOPE)
            else()
                set(_result FALSE PARENT_SCOPE)
            endif()
            return()
        endif()
        set(_result TRUE PARENT_SCOPE)
    else()
        set(_result FALSE PARENT_SCOPE)
    endif()
endfunction()

