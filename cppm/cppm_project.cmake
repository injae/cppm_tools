macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY;WITH_VCPKG" "" "" ${ARGN})
    if(NOT IS_CPPM_LOADED)
        cppm_download_package(cppm-tools
            GIT https://github.com/injae/cppm_tools.git
            GIT_TAG ${CPPM_VERSION}
        )
    endif()
    option(NO_VCPKG OFF)
    if(ARG_WITH_VCPKG)
        _include_vcpkg()
    else()
    endif()
endmacro()

macro(_include_vcpkg)
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
                    list(APPEND CMAKE_TOOLCHAIN_FILE "${vcpkg_toolchains}")
                    list(REMOVE_DUPLICATES CMAKE_TOOLCHAIN_FILE)
                else()
                    set(cppm_detect_vcpkg FALSE)
                endif()
            else()
                set(cppm_detect_vcpkg FALSE)
            endif()
        endif()
    endif()
endmacro()
