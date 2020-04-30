macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY" "" "" ${ARGN})
    if(NOT IS_CPPM_LOADED)
        cppm_download_package(cppm-tools
            GIT https://github.com/injae/cppm_tools.git
            GIT_TAG ${CPPM_VERSION}
        )
    endif()
    _include_vcpkg()
endmacro()

macro(_include_vcpkg)
    option(NO_VCPKG OFF)
    if(NOT NO_VCPKG)
    find_program(vcpkg_exe vcpkg)
    if(NOT vcpkg_exe-NOTFOUND)
        get_filename_component(vcpkg_path ${vcpkg_exe} DIRECTORY CACHE)
        set(vcpkg_toolchains "${vcpkg_path}/scripts/buildsystems/vcpkg.cmake")
        cppkg_print("Detect Vcpkg: ${vcpkg_path}")
        list(APPEND CMAKE_TOOLCHAIN_FILE "${vcpkg_toolchains}")
        cppkg_print("Toolchains: ${CMAKE_TOOLCHAIN_FILE}")
    endif()
    endif()
endmacro()
