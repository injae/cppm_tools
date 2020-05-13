macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY;WITH_VCPKG" "" "" ${ARGN})
    if(NOT IS_CPPM_LOADED)
        cppm_download_package(cppm-tools
            GIT https://github.com/injae/cppm_tools.git
            GIT_TAG ${CPPM_VERSION}
        )
    endif()
    if(ARG_WITH_VCPKG)
        set(NO_VCPKG OFF)
    else()
        set(NO_VCPKG ON)
    endif()
    set(CMAKE_TOOLCHAIN_FILE "${CPPM_CORE}/toolchain.cmake")
    set(CMAKE_PROJECT_INCLUDE "${CPPM_CORE}/set_cppm_install_prefix.cmake")
endmacro()
