macro(_cppm_setting)
  cmake_parse_arguments(ARG "NO_CCACHE;NO_MESSAGE" "" "" ${ARGN})
  if(NOT ARG_NO_MESSAGE)
    message(STATUS "[cppm] Build Project")
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
        set(CMAKE_CXX_COMPILER_LAUNCHER c cache)
        if(NOT DEFINED ARG_NO_MESSAGE)
            message(STATUS "[cppm] Find ccache")
        endif()
    endif()
  endif()
  
  string(REPLACE "\\" "/" HOME "$ENV{HOME}")
  set(CPPM_ROOT ${HOME}/.cppm)
  list(APPEND CMAKE_PREFIX_PATH "${HOME}/.cppm/local/lib/cmake")
  list(APPEND CMAKE_PREFIX_PATH "${HOME}/.cppm/local/lib/pkgconfig")
  list(APPEND CMAKE_MODULE_PATH "${HOME}/.cppm/tool")
  if(NOT ${NO_MESSAGE})
       message(STATUS "[cppm] CPPM_ROOT: ${HOME}/.cppm")
       message(STATUS "[cppm] Compiler Flags:${CMAKE_CXX_FLAGS}")
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
