mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)

if(CPPM_LOAD)
    return()
endif()

if(CPPM_EXTERNAL_TOOLCHAIN_FILE)
    include("${CPPM_EXTERNAL_TOOLCHAIN_FILE}")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
    set(env_home "$ENV{USERPROFILE}")
else()
    set(env_home "$ENV{HOME}")
endif()
string(REPLACE "\\" "/" HOME "${env_home}")
get_filename_component(CPPM_CORE "${CMAKE_CURRENT_LIST_FILE}" PATH)
list(APPEND CMAKE_MODULE_PATH "${CPPM_CORE}")
include(utility/set_cmake_cache)
cppm_set(CPPM_ROOT    "${HOME}/.cppm")
cppm_set(CPPM_PREFIX  "${CPPM_ROOT}")
cppm_set(CPPM_MODULE  "${CPPM_ROOT}/cmake")
cppm_set(CPPM_PKGS    "${CPPM_PREFIX}/cppkg")
cppm_set(CPPM_CACHE   "${CPPM_ROOT}/cache")
cppm_set(CPPM_CORE    "${CPPM_CORE}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_PKGS}")
include(cppm/setting)
include(utility/cppm_print)

_cppm_arch_flag()
_cppm_os_flag()
_cppm_generator()
cppm_set(cppm_target_triplet ${cppm_target_arch}-${cppm_target_base_platform})
_cppm_build_type()
_cppm_rpath()
_cppkg_define_property()
_cppm_ccache()

## with vcpkg
if(NOT NO_VCPKG)
    if(DEFINED ENV{VCPKG_ROOT})
        set(vcpkg_toolchains "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
        list(APPEND CMAKE_TOOLCHAIN_FILE "${vcpkg_toolchains}")
        set(cppm_detect_vcpkg True)
    else()
        find_program(vcpkg_exe vcpkg)
        if(NOT vcpkg_exe-NOTFOUND)
            get_filename_component(vcpkg_path ${vcpkg_exe} DIRECTORY CACHE)
            set(vcpkg_toolchains "${vcpkg_path}/scripts/buildsystems/vcpkg.cmake")
            if(EXISTS ${vcpkg_toolchains})
                set(cppm_detect_vcpkg TRUE)
                include("${vcpkg_toolchains}")
            else()
                set(cppm_detect_vcpkg FALSE)
            endif()
        else()
            set(cppm_detect_vcpkg FALSE)
        endif()
    endif()
endif()

list(APPEND CMAKE_PREFIX_PATH    "${CPPM_PKGS}")
list(APPEND CMAKE_PREFIX_PATH    "${CPPM_ROOT}")
list(APPEND CMAKE_FIND_ROOT_PATH "${CPPM_PKGS}")
list(APPEND CMAKE_FIND_ROOT_PATH "${CPPM_ROOT}")

#cppm_print("Load cppm toolchain")
cppm_set(CPPM_LOAD ON)
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
            CPPM_ROOT
            CPPM_CORE
            cppm_target_arch
            cppm_target_base_platform
            CPPM_EXTERNAL_TOOLCHAIN_FILE
            cppm-target_platform
        )
