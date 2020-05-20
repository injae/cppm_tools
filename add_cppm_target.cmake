include(cppm/create_symlink)
if(TARGET cppm_link)
else()
set(cppm_symlink_file "${CMAKE_BINARY_DIR}/cppm_symlink.cmake")
file(WRITE ${cppm_symlink_file}
"include(${CPPM_CORE}/cppm/create_symlink.cmake)
set(CPPM_ROOT \"${CPPM_ROOT}\")
set(CPPM_TARGET_BINARY_DIR \"${CMAKE_BINARY_DIR}\")
cppm_create_symlink(${CMAKE_INSTALL_PREFIX})
")
add_custom_target(cppm_link COMMAND "${CMAKE_COMMAND}" -P "${cppm_symlink_file}")
set_property(TARGET cppm_link PROPERTY FOLDER "CMakePredefinedTargets")
include(cppm/uninstall)
endif()

# visual debug release export bugfix
#if(NOT cppm_generator_type STREQUAL "visual") ## visual studio build type problem 
#    set(cppkg_install_type "release")
#else()
#    set(cppkg_install_type "${cppm_build_type}")
#endif()
#
#if("${CMAKE_PROJECT_VERSION}" STREQUAL "" OR (CPPKG_GIT_VERSION))
#    cppm_set(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${cppkg_install_type}/${CMAKE_PROJECT_NAME}")
#else()
#    cppm_set(CMAKE_INSTALL_PREFIX "${CPPM_PKGS}/${cppkg_install_type}/${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}")
#endif()


