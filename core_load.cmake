string(REPLACE "\\" "/" HOME "$ENV{HOME}")
set(CPPM_ROOT   ${HOME}/.cppm)
set(CPPM_TOOL   ${CPPM_ROOT}/tool)
set(CPPM_MODULE ${CPPM_ROOT}/cmake)
set(CPPM_CORE   ${CPPM_MODULE}/core)
list(APPEND CMAKE_MODULE_PATH "${CPPM_ROOT}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_TOOL}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_MODULE}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_CORE}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_CORE}/${CPPM_VERSION}")

include(cppm/cxx_standard)
include(cppm/compiler_option)
include(cppm/setting)
include(cppkg/find)
include(cppm/target_define)
include(cppm/target_dependencies)
include(cppm/target_install)
include(cppkg/download)
