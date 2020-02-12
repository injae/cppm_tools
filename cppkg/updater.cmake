string(REPLACE "\\" "/" HOME "$ENV{HOME}")
set(CPPM_ROOT ${HOME}/.cppm)

cppm_download_package(cppkg
    GIT https://github.com/injae/cppkg.git
    PATH ${CPPM_ROOT}/repo/cppkg
)
