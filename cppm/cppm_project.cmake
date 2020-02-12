macro(cppm_project)
    cmake_parse_arguments(ARG "NIGHTLY" "" "" ${ARGN})
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools/download.cmake.in
"cmake_minimum_required(VERSION 3.6)
project(cpp-tool-${CPPM_VERSION}-install NONE)
include(ExternalProject)
ExternalProject_Add(cppm-tools-${CPPM_VERSION}
    GIT_REPOSITORY https://github.com/injae/cppm_tools.git
    GIT_TAG ${CPPM_VERSION}
    SOURCE_DIR ${CPPM_CORE}
    BINARY_DIR ${CPPM_CACHE}/cppm_tools/1.0.9/build
    #QUIET
)"
)
    configure_file(${CMAKE_CURRENT_BINARY_DIR}/cppm-tools/download.cmake.in
                ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools/CMakeLists.txt)
    execute_process(COMMAND "${CMAKE_COMMAND} ." WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools)
    execute_process(COMMAND "${CMAKE_COMMAND} --build ." WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools)
endmacro()
