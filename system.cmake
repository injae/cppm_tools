macro(home_directory) # return HOME
  string(REPLACE "\\" "/" HOME "$ENV{HOME}")
endmacro()

