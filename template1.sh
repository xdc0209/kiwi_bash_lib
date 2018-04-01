#!/bin/bash

####################################################################################################
# Make sure to execute this script with bash. Bash works well on suse, redhat, aix.##
# 确保以bash执行此脚本。Bash在suse、redhat、aix上表现很出色。##
[ -z "$BASH" ] && echo "Please use bash to run this script [ bash $0 ] or make sure the first line of this script [ $0 ] is [ #!/bin/bash ]." && exit 1
####################################################################################################

####################################################################################################
# Get the absolute path of this script. The code snippets below are taken from virgo/bin/startup.sh. Tested on suse, redhat, aix.##
# 获取脚本的绝对路径。下面的代码片段取自virgo/bin/startup.sh。在suse、redhat、aix上经过测试。##
SCRIPT="$0"
# SCRIPT may be an arbitrarily deep series of symlinks. Loop until we have the concrete path.##
# 脚本可能是一系列任意深度的符号链接。循环,直到我们有了具体的路径。##
while [ -h "$SCRIPT" ]
do
    ls=$(ls -ld "$SCRIPT")
    # Drop everything prior to ->##
    # 去掉->之前的内容##
    link=$(expr "$ls" : '.*-> \(.*\)$')
    if expr "$link" : '/.*' >/dev/null; then
        SCRIPT="$link"
    else
        SCRIPT=$(dirname "$SCRIPT")/"$link"
    fi
done
BASE_DIR=$(cd $(dirname $SCRIPT) && pwd)
BASE_NAME=$(basename $SCRIPT .sh)
####################################################################################################

log=$BASE_DIR/$BASE_NAME.log

####################################################################################################
# Loading of common libraries.##
# 加载通用类库。##
[ -z "$comm_lib_path" ] && [ -d "$comm_lib_dir" ] && [ -f "$comm_lib_dir/comm_lib.sh" ] && comm_lib_path=$comm_lib_dir/comm_lib.sh
[ -z "$comm_lib_path" ] && [ -f "$BASE_DIR/comm_lib.sh" ] && comm_lib_path=$BASE_DIR/comm_lib.sh
[ -z "$comm_lib_path" ] && echo "File [ comm_lib.sh ] is not found. Please check." && exit 1
source $comm_lib_path
[ $? -ne 0 ] && echo "Source file [ $comm_lib_path ] failed. Use cmd [ source $comm_lib_path ] to check." && exit 1
####################################################################################################

# 校验执行的用户。##
if [ $(whoami) != "root" ]; then
    echo "You must run with [ root ] user."
    exit 1
fi

absolute_script_path=$(get_absolute_script_path)
[ $? -ne 0 ] && die "get_absolute_script_path failed."
[ -z "$absolute_script_path" ] && die "get_absolute_script_path failed."

check_space /home 2000

while true
do
    print_info "==== Before ==================="
    dir=/opt
    [ -d "$dir" ] && ls -l $dir
    print_info "==== After ===================="
    echo
    echo

    sleep 10
done
