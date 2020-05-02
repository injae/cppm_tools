
macro(cppm_cxx_standard _version)
    include(utility/set_cmake_cache)
    include(utility/cppm_print)
    set_cache(CMAKE_CXX_STANDARD ${_version} STRING)
    set_cache(CMAKE_CXX_STANDARD_REQUIRED ON BOOL)
    set(cxx_standard ${_version})

    cppm_print("c++ version: ${cxx_standard}")

    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        if("${_version}" STREQUAL "17")
            add_compiler_option(CMAKE_CXX_FLAGS "/std:c++${_version}")
        endif()
        set_cache(CMAKE_CXX_EXTENSIONS OFF BOOL)
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android")
        add_compiler_option(CMAKE_CXX_FLAGS_INIT "-std:c++${_version}")
        set_cache(CMAKE_CXX_EXTENSIONS OFF BOOL)
    else()
        add_compiler_option(CMAKE_CXX_FLAGS "-std=c++${_version}")
        set_cache(CMAKE_CXX_EXTENSIONS ON BOOL)
    endif()

endmacro()
