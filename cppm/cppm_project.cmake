macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY" "" "" ${ARGN})
    cppm_download_package(cppm_tools-${CPPM_VERSION}
        GIT https://github.com/injae/cppm_tools.git
        GIT_TAG ${CPPM_VERSION}
        PATH ${CPPM_CORE}
    )
endmacro()
