string(REPLACE "\\" "/" HOME "$ENV{HOME}")
set(CPPM_ROOT   ${HOME}/.cppm)
set(CPPM_TOOL   ${CPPM_ROOT}/tool)
set(CPPM_MODULE ${CPPM_ROOT}/cmake)
set(CPPM_CORE   ${CPPM_MODULE}/core)
list(APPEND CMAKE_MODULE_PATH "${CPPM_ROOT}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_TOOL}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_MODULE}")
list(APPEND CMAKE_MODULE_PATH "${CPPM_CORE}")

