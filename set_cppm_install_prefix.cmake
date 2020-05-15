if(USE_CPPM_PATH)
    include(${CPPM_CORE}/utility/set_cmake_cache.cmake)
    cppm_set(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}")
endif()
