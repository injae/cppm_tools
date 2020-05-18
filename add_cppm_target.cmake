include(cppm/create_symlink)
set(cppm_symlink_file "${CMAKE_BINARY_DIR}/cppm_symlink.cmake")
file(WRITE ${cppm_symlink_file}
"include(${CPPM_CORE}/cppm/create_symlink.cmake)
set(CPPM_ROOT \"${CPPM_ROOT}\")
cppm_create_symlink(${CMAKE_INSTALL_PREFIX})
")
add_custom_target(cppm_link COMMAND "${CMAKE_COMMAND}" -P "${cppm_symlink_file}")
set_property(TARGET cppm_link PROPERTY FOLDER "CMakePredefinedTargets")

