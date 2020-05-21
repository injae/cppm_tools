macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY;WITH_VCPKG" "" "" ${ARGN})
    if(NOT IS_CPPM_LOADED)
        cppm_download_package(cppm-tools
            GIT https://github.com/injae/cppm_tools.git
            GIT_TAG ${CPPM_TOOLS_VERSION}
            PATH  ${CPPM_CPPKG}/cppm-tools-${CPPM_TOOLS_VERSION}
        )
    endif()
    if(ARG_WITH_VCPKG)
        set(WITH_VCPKG ON)
    endif()
    if("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
        set(CMAKE_TOOLCHAIN_FILE "${CPPM_CORE}/toolchain.cmake")
    else()
        if("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "^${CPPM_CPPKG}/cppm-tools-.*/toolchain.cmake")
            set(CMAKE_TOOLCHAIN_FILE "${CPPM_CORE}/toolchain.cmake")
        else()
            set(CPPM_EXTERNAL_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}")
            set(CMAKE_TOOLCHAIN_FILE "${CPPM_CORE}/toolchain.cmake")
        endif()
    endif()
endmacro()
