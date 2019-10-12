macro(_cppm_setting)
  cmake_parse_arguments(ARG "NO_CCACHE;NO_MESSAGE" "" "" ${ARGN})
  if(NOT ${CMAKE_PROJECT_NAME} MATCHES ${PROJECT_NAME})
      set(SUB_PROJECT TRUE)
      set(NO_MESSAGE TRUE)
      set(ARG_NO_CCACHE FALSE)
  else()
      set(SUB_PROJECT FALSE)
  endif()
  if(ARG_NO_MESSAGE)
      set(NO_MESSAGE TRUE)
  endif()

  if(NOT NO_MESSAGE)
      message(STATUS "[cppm] Target: ${PROJECT_NAME}")
      message(STATUS "[cppm] CMake Version: ${CMAKE_VERSION}")
      message(STATUS "[cppm] System Name: ${CMAKE_SYSTEM_NAME}")
      message(STATUS "[cppm] System Version: ${CMAKE_SYSTEM_VERSION}")
      message(STATUS "[cppm] System Processor: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
      message(STATUS "[cppm] Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
      message(STATUS "[cppm] Generator: ${CMAKE_GENERATOR}")
  endif()

  if(NOT ARG_NO_CCACHE)
    find_program(CCACHE_EXE ccache)
    if(CCACHE_EXE)
        set(CMAKE_CXX_COMPILER_LAUNCHER ccache)
        if(NOT NO_MESSAGE)
            message(STATUS "[cppm] Find ccache")
        endif()
    endif()
  endif()

  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
  
  string(REPLACE "\\" "/" HOME "$ENV{HOME}")
  set(CPPM_ROOT ${HOME}/.cppm)
  list(APPEND CMAKE_PREFIX_PATH "${CPPM_ROOT}/local/lib/cmake")
  list(APPEND CMAKE_PREFIX_PATH "${CPPM_ROOT}/local/lib64/cmake")
  list(APPEND CMAKE_PREFIX_PATH "${CPPM_ROOT}/local/lib/pkgconfig")
  list(APPEND CMAKE_PREFIX_PATH "${CPPM_ROOT}/local/lib64/pkgconfig")
  list(APPEND CMAKE_MODULE_PATH "${CPPM_ROOT}/tool")
  list(APPEND CMAKE_MODULE_PATH "${CPPM_ROOT}/cmake")
  list(APPEND CMAKE_MODULE_PATH "${CPPM_ROOT}/cmake/core")
  if(NOT NO_MESSAGE)
       message(STATUS "[cppm] cppm_root: ${CPPM_ROOT}")
  endif()

  if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
      add_definitions(-DSYSTEM_LINUX)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
      add_definitions(-DSYSTEM_DARWIN)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "AIX")
      add_definitions(-DSYSTEM_AIX)
  elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
      add_definitions(-DSYSTEM_WINDOWS)
  endif()
  set(CMAKE_CXX_FLAGS "" CACHE STRING "compiler flags" FORCE)
endmacro()
