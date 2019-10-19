macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY" "" "" ${ARGN})
    FetchContent_Populate(cmake-tools-${CPPM_VERSION}
        GIT_REPOSITORY https://github.com/injae/cppm_tools.git
        GIT_TAG        ${CPPM_VERSION}
        SOURCE_DIR     ${CPPM_CORE}/${CPPM_VERSION}
        QUIET
    )

    FetchContent_Populate(${CPPM_VERSION}
        GIT_REPOSITORY https://github.com/injae/cppkg.git
        SOURCE_DIR     ${CPPM_ROOT}/repo
        QUIET
    )
endmacro()
