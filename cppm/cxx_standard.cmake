macro(_cppm_cxx_standard _version)
    set(CMAKE_CXX_STANDARD ${_version})
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    set(cxx_standard ${_version})
    if(NOT NO_MESSAGE)
        message(STATUS "[cppm] c++ version: ${cxx_standard}")
    endif()

    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++${_version}")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++${_version}")
    endif()


endmacro()
