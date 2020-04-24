macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY" "" "" ${ARGN})
    if(NOT IS_CPPM_LOADED)
        cppm_download_package(cppm-tools
            GIT https://github.com/injae/cppm_tools.git
            GIT_TAG ${CPPM_VERSION}
        )
    endif()
    include(CMakeDependentOption)
endmacro()
