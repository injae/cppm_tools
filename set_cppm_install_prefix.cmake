message("---------------install with cppm prefix")
if(USE_CPPM_PATH)
    include(utility/set_cmake_cache)
    set_cache(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}" STRING)
endif()
