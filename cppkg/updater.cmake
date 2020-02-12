string(REPLACE "\\" "/" HOME "$ENV{HOME}")
set(CPPM_ROOT ${HOME}/.cppm)

include(FetchContent)
FetchContent_Populate(cppkg
    GIT_REPOSITORY https://github.com/injae/cppkg.git
    SOURCE_DIR     ${CPPM_ROOT}/repo/cppkg
    QUIET
)

#file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools/download.cmake.in
#"cmake_minimum_required(VERSION 3.6)
#project(cppkg-updater NONE)
#include(ExternalProject)
#ExternalProject_Add(cppkg-updater
#    GIT_REPOSITORY https://github.com/injae/cppkg.git
#    SOURCE_DIR ${CPPM_ROOT}/repo/cppkg
#    BINARY_DIR ${CPPM_CACHE}/repo/cppkg/git/build
#    #QUIET
#)"
#)
#    configure_file(${CMAKE_CURRENT_BINARY_DIR}/cppm-tools/download.cmake.in
#                ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools/CMakeLists.txt)
#    execute_process(COMMAND "${CMAKE_COMMAND} ." WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools)
#    execute_process(COMMAND "${CMAKE_COMMAND} --build ." WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cppm-tools)
