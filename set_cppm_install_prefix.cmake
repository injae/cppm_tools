message("---------------install with cppm prefix")
if(USE_CPPM_PATH)
    set(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}" CACHE STRING)
endif()
