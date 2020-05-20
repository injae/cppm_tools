include(cppm/setting)
include(utility/set_cmake_cache)
_cppm_set_prefix()
_cppm_compiler_type()
cppm_set(cppm_target_triplet ${cppm_target_arch}-${cppm_target_platform}-${cppm_compiler_type})
include(cppm/create_symlink)

if(USE_CPPM_PATH)
    if(TARGET cppm_link )
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
endif()

