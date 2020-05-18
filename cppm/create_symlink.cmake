function(cppm_create_symlink)
    cmake_parse_arguments(ARG "" "" "" ${ARGN})
    list(GET ARG_UNPARSED_ARGUMENTS 0 path)
    file(GLOB bins "${path}/bin/*")
    foreach(bin IN LISTS bins)
        get_filename_component(bin_name ${bin} NAME)
        message(STATUS "[cppm] Linking: ${bin} --> ${CMAKE_ROOT}/bin/${bin_name}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "${bin}" "${CPPM_ROOT}/bin/${bin_name}")
    endforeach()
endfunction()
