cppm_print("install with cppm prefix")
if(USE_CPPM_PATH)
    set_cache(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}" STRING)
endif()
