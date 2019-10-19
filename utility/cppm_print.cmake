function(cppm_print)
    foreach(print_message ${ARGV})
        if(NOT NO_MESSAGE)
            message(STATUS "[cppm] ${message}")
        endif()
    endforeach()
endfunction()

function(cppm_error_print)
    foreach(print_message ${ARGV})
        if(NOT NO_MESSAGE)
            message(STATUS "[cppm-error] ${message}")
        endif()
    endforeach()
    message(FATAL_ERROR "")
endfunction()
