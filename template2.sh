#!/bin/bash

[ -z "$BASH" ] && echo "Please use bash to run this script [ bash $0 ] or make sure the first line of this script [ $0 ] is [ #!/bin/bash ]." && exit 1

BASE_DIR=$(cd $(dirname $0) && pwd)
BASE_NAME=$(basename $0 .sh)

log=$BASE_DIR/$BASE_NAME.log

[ -z "$comm_lib_path" ] && [ -d "$comm_lib_dir" ] && [ -f "$comm_lib_dir/comm_lib.sh" ] && comm_lib_path=$comm_lib_dir/comm_lib.sh
[ -z "$comm_lib_path" ] && [ -f "$BASE_DIR/comm_lib.sh" ] && comm_lib_path=$BASE_DIR/comm_lib.sh
[ -z "$comm_lib_path" ] && echo "File [ comm_lib.sh ] is not found. Please check." && exit 1
source $comm_lib_path
[ $? -ne 0 ] && echo "Source file [ $comm_lib_path ] failed. Use cmd [ source $comm_lib_path ] to check." && exit 1

# 以下是业务代码##
check_space /home 2000
check_space /tmp  1000
