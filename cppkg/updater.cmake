string(REPLACE "\\" "/" HOME "$ENV{HOME}")
set(CPPM_ROOT ${HOME}/.cppm)

include(FetchContent)
FetchContent_Populate(cppkg
    GIT_REPOSITORY https://github.com/injae/cppkg.git
    SOURCE_DIR     ${CPPM_ROOT}/repo/cppkg
    QUIET
)
