#!/bin/bash

#############################################################################################################
# 名称: comm_lib.sh                                                                                        ##
# 功能: 提供公共函数库                                                                                     ##
# 声明: [公开]: 对外公开，供外部脚本调用                                                                   ##
#       [私有]: 框架私有，内部调用，不保证其完全通用及有效                                                 ##
#       [废弃]: 废弃方法，后续版本中可能会被移除，不保证其完全通用及有效                                   ##
# 函数列表: -----------------------------------------------------------------------------------------------##
# function echo_to_stderr()                         重定向stdout到stderr*****************************[私有]##
# function echo_red()                               输出红色文字*************************************[公开]##
# function echo_green()                             输出绿色文字*************************************[公开]##
# function echo_yellow()                            输出黄色文字*************************************[公开]##
# function echo_blue()                              输出蓝色文字*************************************[公开]##
# function print_error()                            输出错误信息到屏幕和日志*************************[公开]##
# function print_info()                             输出信息到屏幕和日志*****************************[公开]##
# function log_error()                              输出错误信息到日志*******************************[公开]##
# function log_info()                               输出信息到日志***********************************[公开]##
# function die()                                    输出错误信息到屏幕和日志并退出*******************[公开]##
# function get_bash_stack_info()                    获取bash调用的堆栈信息***************************[私有]##
# function get_absolute_script_path()               获取脚本的绝对路径*******************************[私有]##
# function debug_state_query()                      查询脚本的调试状态*******************************[私有]##
# function debug_state_close()                      关闭脚本的调试状态*******************************[公开]##
# function debug_state_resume()                     恢复脚本的调试状态*******************************[公开]##
# function error_trap()                             错误陷阱*****************************************[私有]##
# function debug_trap()                             调试陷阱*****************************************[私有]##
# function sed_i()                                  sed -i的通用实现*********************************[公开]##
# function sed_i_add_to_next_line()                 在匹配行的下一行添加文本*************************[公开]##
# function sed_i_add_to_pre_line()                  在匹配行的前一行添加文本*************************[公开]##
# function get_cfg_value()                          读取配置文件配置项*******************************[公开]##
# function set_cfg_value()                          修改配置文件配置项*******************************[公开]##
# function update_config()                          合并旧Properties中的值到新Properties*************[公开]##
# function get_process_stack_info_and_login_info()  收集脚本进程调用堆栈信息和登录信息***************[私有]##
# function get_remote_terminal()                    获取当前终端的客户端IP***************************[私有]##
# function log_operation()                          打印操作日志*************************************[私有]##
# function log_operation_start()                    打印入口操作日志*********************************[公开]##
# function log_operation_end()                      打印出口操作日志*********************************[公开]##
# function get_os_type()                            获取操作系统类型*********************************[公开]##
# function check_space()                            检查目录所在的分区剩余空间是否足够***************[公开]##
# function is_dir_empty()                           检查目录是否为空*********************************[公开]##
# function get_dir_user_name()                      获取目录的用户***********************************[公开]##
# function get_dir_group_name()                     获取目录的用户组*********************************[公开]##
# function chmod_all_files_and_dirs()               修改文件和目录权限*******************************[公开]##
# function is_substring()                           字符串1是否为字符串2的子串***********************[公开]##
# function check_port_available()                   检查端口是否可用*********************************[公开]##
# function check_ip_legal()                         检查IP是否合法***********************************[公开]##
# function ip_to_dec()                              转化IP为10进制数字*******************************[公开]##
# function is_same_subnet()                         判断两个IP是否为相同网段*************************[公开]##
# function test_network_connectivity()              测试网络连通性***********************************[公开]##
# function uncompress_pkg()                         解压压缩文件*************************************[公开]##
# function check_password_expired()                 检查用户的密码是否过期***************************[公开]##
# function file_rotate()                            滚动文件*****************************************[公开]##
#############################################################################################################

#############################################################################################################
# 编写函数注意：                                                                                           ##
# 根据函数是否对系统状态做出改变将函数分为两类：                                                           ##
#     查询类：                                                                                             ##
#        （1）在子进程中执行，并将结果赋给一个变量，如get_cfg_value                                        ##
#        （2）判断一个条件是否满足等，如is_substring                                                       ##
#     操作类：                                                                                             ##
#        （1）修改，如set_cfg_value                                                                        ##
#        （2）检验，如check_ip_legal                                                                       ##
#                                                                                                          ##
# 对于退出函数命令，一般查询类使用return，操作类使用exit，这样实现有助于调用者编写简洁的代码。             ##
# 对于查询类函数，执行完成调用后，调用者最好通过判断返回结果是否为空，判断是否执行成功。                   ##
# 对于操作类函数，执行报错直接退出，调用调无需判断是否执行成功。                                           ##
#                                                                                                          ##
# 建议考虑函数的定义位置，但是函数的定义顺序其实可以不按调用关系排序。                                     ##
# 这是因为类库只做函数的定义，函数调用时才会产生依赖。                                                     ##
#                                                                                                          ##
#############################################################################################################

#############################################################################################################
# Redirect stdout as stderr.##
# 重定向stdout到stderr。##
#############################################################################################################
function echo_to_stderr()
{
    echo "$*" 1>&2
}

#############################################################################################################
# Print the red words.##
# 输出红色文字。##
#############################################################################################################
function echo_red()
{
    # 30黑, 31红, 32绿, 33黄, 34蓝, 35紫, 36青绿, 37白(灰)。##
    echo -e "\e[31;1m$*\e[0m"
}

#############################################################################################################
# Print the green words.##
# 输出绿色文字。##
#############################################################################################################
function echo_green()
{
    # 30黑, 31红, 32绿, 33黄, 34蓝, 35紫, 36青绿, 37白(灰)。##
    echo -e "\e[32;1m$*\e[0m"
}

#############################################################################################################
# Print the yellow words.##
# 输出黄色文字。##
#############################################################################################################
function echo_yellow()
{
    # 30黑, 31红, 32绿, 33黄, 34蓝, 35紫, 36青绿, 37白(灰)。##
    echo -e "\e[33;1m$*\e[0m"
}

#############################################################################################################
# Print the blue words.##
# 输出蓝色文字。##
#############################################################################################################
function echo_blue()
{
    # 30黑, 31红, 32绿, 33黄, 34蓝, 35紫, 36青绿, 37白(灰)。##
    echo -e "\e[34;1m$*\e[0m"
}

#############################################################################################################
# Print the error information to the screen(redirect stdout as stderr) and the log.##
# 输出错误信息到屏幕(重定向stdout到stderr)和日志。##
#############################################################################################################
function print_error()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local date_time="$(date '+%F %T')"
    local caller_shell_line="${BASH_LINENO[0]}"
    local caller_shell_path="$(basename $(cd $(dirname ${BASH_SOURCE[1]}) && pwd))/$(basename ${BASH_SOURCE[1]})"

    [ -n "$log" ] && echo "[$date_time ERROR $caller_shell_path:$caller_shell_line]: $*" >>$log

    echo -e "[$date_time \e[31;1mERROR\e[0m]: $*" 1>&2

    debug_state_resume
}

#############################################################################################################
# Print the information to the screen and the log.##
# 输出信息到屏幕和日志。##
#############################################################################################################
function print_info()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local date_time="$(date '+%F %T')"
    local caller_shell_line="${BASH_LINENO[0]}"
    local caller_shell_path="$(basename $(cd $(dirname ${BASH_SOURCE[1]}) && pwd))/$(basename ${BASH_SOURCE[1]})"

    [ -n "$log" ] && echo "[$date_time INFO  $caller_shell_path:$caller_shell_line]: $*" >>$log

    echo -e "[$date_time \e[32;1mINFO \e[0m]: $*"

    debug_state_resume
}

#############################################################################################################
# Print the error information to the log.##
# 输出错误信息到日志。##
#############################################################################################################
function log_error()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local date_time="$(date '+%F %T')"
    local caller_shell_line="${BASH_LINENO[0]}"
    local caller_shell_path="$(basename $(cd $(dirname ${BASH_SOURCE[1]}) && pwd))/$(basename ${BASH_SOURCE[1]})"

    [ -n "$log" ] && echo "[$date_time ERROR $caller_shell_path:$caller_shell_line]: $*" >>$log

    debug_state_resume
}

#############################################################################################################
# Print the information to the log.##
# 输出信息到日志。##
#############################################################################################################
function log_info()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local date_time="$(date '+%F %T')"
    local caller_shell_line="${BASH_LINENO[0]}"
    local caller_shell_path="$(basename $(cd $(dirname ${BASH_SOURCE[1]}) && pwd))/$(basename ${BASH_SOURCE[1]})"

    [ -n "$log" ] && echo "[$date_time INFO  $caller_shell_path:$caller_shell_line]: $*" >>$log

    debug_state_resume
}

#############################################################################################################
# Print the error information to the screen(redirect stdout as stderr) and the log and exit.##
# 输出错误信息到屏幕(重定向stdout到stderr)和日志并退出。##
#############################################################################################################
function die()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local date_time="$(date '+%F %T')"
    local caller_shell_line="${BASH_LINENO[0]}"
    local caller_shell_path="$(basename $(cd $(dirname ${BASH_SOURCE[1]}) && pwd))/$(basename ${BASH_SOURCE[1]})"
    local caller_shell_stack_info="$(get_bash_stack_info)"
    local caller_process_stack_info_and_login_info="$(get_process_stack_info_and_login_info)"

    [ -n "$log" ] && echo "[$date_time ERROR $caller_shell_path:$caller_shell_line]: $*" >>$log
    [ -n "$log" ] && echo "[$date_time ERROR $caller_shell_path:$caller_shell_line]: Bash stack info: [ $caller_shell_stack_info ]." >>$log
    [ -n "$log" ] && echo "[$date_time ERROR $caller_shell_path:$caller_shell_line]: Process stack info and login info are shown below:" >>$log
    [ -n "$log" ] && echo "$caller_process_stack_info_and_login_info" >>$log

    echo -e "[$date_time \e[31;1mERROR\e[0m]: $*" 1>&2
    echo -e "[$date_time \e[31;1mERROR\e[0m]: Bash stack info: [ $caller_shell_stack_info ]." 1>&2
    echo -e "[$date_time \e[31;1mERROR\e[0m]: Process stack info and login infoare shown below:" 1>&2
    echo -e "$caller_process_stack_info_and_login_info" 1>&2

    [ -n "$log" ] && echo -e "[$date_time \e[31;1mERROR\e[0m]: See log [ $log ] for details." 1>&2

    debug_state_resume

    exit 1
}

#############################################################################################################
# Get bash stack info.##
# 获取bash调用的堆栈信息。##
#############################################################################################################
function get_bash_stack_info()
{
    for ((i = ${#FUNCNAME[*]} - 1; i >= 0; i--))
    do
        if [ $i -ge 1 ]; then
            local bash_stack_info="$bash_stack_info, ${BASH_SOURCE[i]}:${FUNCNAME[i]}:${BASH_LINENO[i - 1]}"
        else
            local bash_stack_info="$bash_stack_info, ${BASH_SOURCE[i]}:${FUNCNAME[i]}:$LINENO"
        fi
    done

    # Delete the first space.##
    # 删除第一个空格。##
    local bash_stack_info=${bash_stack_info:1}

    # Delete the last comma.##
    # 删除最后一个逗号。##
    local bash_stack_info=${bash_stack_info%,}

    echo $bash_stack_info
}

#############################################################################################################
# Get the absolute path of this script. The code snippets below are taken from virgo/bin/startup.sh. Tested on suse, redhat, aix.##
# 获取脚本的绝对路径。下面的代码片段取自virgo/bin/startup.sh。在suse、redhat、aix上经过测试。##
# SCRIPT may be an arbitrarily deep series of symlinks. Loop until we have the concrete path.##
# 脚本可能是一系列任意深度的符号链接。循环,直到我们有了具体的路径。##
#############################################################################################################
function get_absolute_script_path()
{
    if [ $# -eq 0 ]; then
        # $0 is the script path that invokes the source command.##
        # $0为调用source命令的脚本路径。##
        local SCRIPT="$0"
    elif [ $# -eq 1 ]; then
        # $1 is the first argument of the method.##
        # $1为方法的第一个参数。##
        local SCRIPT="$1"
    else
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME [script_path] ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    while [ -h "$SCRIPT" ]
    do
        local ls=$(ls -ld "$SCRIPT")
        # Drop everything prior to ->##
        # 去掉->之前的内容##
        link=$(expr "$ls" : '.*-> \(.*\)$')
        if expr "$link" : '/.*' >/dev/null; then
            local SCRIPT="$link"
        else
            local SCRIPT=$(dirname "$SCRIPT")/"$link"
        fi
    done

    local SCRIPT_DIR=$(cd $(dirname $SCRIPT) && pwd)
    local SCRIPT_NAME=$(basename $SCRIPT)
    local SCRIPT_PATH=$SCRIPT_DIR/$SCRIPT_NAME

    echo "$SCRIPT_PATH"
}

#############################################################################################################
# Query debug state.##
# 查询脚本的调试状态。##
#############################################################################################################
function debug_state_query()
{
    echo "${SHELLOPTS}" | grep -q "xtrace"
    if [ $? -eq 0 ]; then
        echo "-x"
    else
        echo "+x"
    fi
}

#############################################################################################################
# Close debug state.##
# 关闭脚本的调试状态。##
#############################################################################################################
function debug_state_close()
{
    {
        # Use stack to record the current debug state to support nested invocations. Here is push operation.##
        # 使用栈记录当前调试状态，以支持嵌套调用。此处为压栈操作。##
        debug_state=$setx
        debug_state_stack=("${debug_state_stack[@]}" $debug_state)

        export setx="+x"
        set $setx
    } >/dev/null 2>&1
}

#############################################################################################################
# Resume debug state.##
# 恢复脚本的调试状态。##
#############################################################################################################
function debug_state_resume()
{
    {
        # Use stack to record the current debug state to support nested invocations. Here is pop operation.##
        # 使用栈记录当前调试状态，以支持嵌套调用。此处为弹栈操作。##
        [ ${#debug_state_stack[@]} -le 0 ] && return
        debug_state=${debug_state_stack[${#debug_state_stack[@]} - 1]}
        debug_state_stack=(${debug_state_stack[@]:0:$((${#debug_state_stack[@]} - 1))})

        export setx=$debug_state
        set $setx
    } >/dev/null 2>&1
}

#############################################################################################################
# When a command returns a nonzero state (on behalf of the command is not executed successfully), execute the method.##
# 当一条命令返回非零状态时(代表命令执行不成功)，执行此方法。##
#############################################################################################################
function error_trap()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local script_path=$(get_absolute_script_path $1)
    local line_number=$2
    local cmd_status=$3
    local line_content=$(sed -n "$line_number p" $script_path)
    local process_stack_info_and_login_info="$(get_process_stack_info_and_login_info)"

    echo_red "ERROR: Cmd [ $script_path:$line_number:$line_content ] exited with status $cmd_status."
    echo_red "Script Path: $script_path"
    echo_red "Line Number: $line_number"
    echo_red "Line Content: $line_content"
    echo_red "Process stack info and login info are shown below:"
    echo_red "$process_stack_info_and_login_info"
    echo_red

    [ -n "$log" ] && echo "ERROR: Cmd [ $script_path:$line_number:$line_content ] exited with status $cmd_status." >>$log
    [ -n "$log" ] && echo "Script Path: $script_path"                                                              >>$log
    [ -n "$log" ] && echo "Line Number: $line_number"                                                              >>$log
    [ -n "$log" ] && echo "Line Content: $line_content"                                                            >>$log
    [ -n "$log" ] && echo "Process stack info and login info are shown below:"                                     >>$log
    [ -n "$log" ] && echo "$process_stack_info_and_login_info"                                                     >>$log
    [ -n "$log" ] && echo                                                                                          >>$log

    debug_state_resume

    exit 1
}

#############################################################################################################
# Before each command execution, execute this method.##
# 脚本中每一条命令执行之前，执行此方法。##
#############################################################################################################
function debug_trap()
{
    {
        debug_state_close
    } >/dev/null 2>&1

    local script_path=$(get_absolute_script_path $1)
    local line_number=$2
    local line_content=$(sed -n "$line_number p" $script_path)

    echo
    echo_green "DEBUG: Press <Enter> to continue."
    echo_green "Script Path: $script_path"
    echo_green "Line Number: $line_number"
    echo_green "Line Content: $line_content"
    read -s var

    debug_state_resume
}

#############################################################################################################
# Common implementation of sed -i. AIX not support sed -i. Tested on suse, redhat, aix.##
# sed -i的通用实现。Aix不支持sed -i。在suse、redhat、aix上经过测试。##
# Function sed_i will sed file and save file.##
# 方法sed_i将sed文件并保存文件。##
# Sample: sed_i '/to_be_deleted/d' /tmp/tmp.cfg
# 样例：  sed_i '/to_be_deleted/d' /tmp/tmp.cfg
#############################################################################################################
function sed_i()
{
    if [ $# -ne 2 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <sed_subcommand> <file_path> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local sed_subcommand=$1
    local file_path=$2

    [ ! -f "$file_path" ] && die "File [ $file_path ] is missing, please check."

    sed "$sed_subcommand" $file_path >$file_path.tmp
    [ $? -ne 0 ] && die "Exec [ sed '$sed_subcommand' $file_path ] failed."

    cat $file_path.tmp >$file_path
    rm $file_path.tmp
}

#############################################################################################################
# Append text to the next line of matching line. AIX not support sed -i and the command /a (add text to next line) on aix is particular. Tested on suse, redhat, aix.##
# 在匹配行的下一行添加文本。Aix不支持sed -i，且命令/a(添加文本到下一行)在Aix上比较特殊。在suse、redhat、aix上经过测试。##
# Function sed_i_add_to_next_line will add text to next line and save file.##
# 方法sed_i_add_to_next_line将添加内容到下一行，并保存文件。##
# Sample: sed_i_add_to_next_line 'sed_match_pattern' 'sed_text_to_add' /tmp/tmp.cfg
# 样例：  sed_i_add_to_next_line 'sed_match_pattern' 'sed_text_to_add' /tmp/tmp.cfg
#############################################################################################################
function sed_i_add_to_next_line()
{
    if [ $# -ne 3 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <sed_match_pattern> <sed_text_to_add> <file_path> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local sed_match_pattern=$1
    local sed_text_to_add=$2
    local file_path=$3

    [ ! -f "$file_path" ] && die "File [ $file_path ] is missing, please check."

    # Note: don't modify the format, beacuse the command /a (add text to next line) on aix is particular.##
    # 提示: 不要修改格式, 因为命令/a(添加文本到下一行)在Aix上比较特殊。##
    sed "/$sed_match_pattern/"'a\
'"$sed_text_to_add" $file_path >$file_path.tmp
    [ $? -ne 0 ] && die "Exec [ sed_i_add_to_next_line '$sed_match_pattern' '$sed_text_to_add' '$file_path' ] failed."

    cat $file_path.tmp >$file_path
    rm $file_path.tmp
}

#############################################################################################################
# Insert text to the previous line of matching line. AIX not support sed -i and the command /i (add text to next line) on aix is particular. Tested on suse, redhat, aix.##
# 在匹配行的前一行添加文本。Aix不支持sed -i，且命令/i(添加文本到下一行)在Aix上比较特殊。在suse、redhat、aix上经过测试。##
# Function sed_i_add_to_pre_line will add text to previous line and save file.##
# 方法sed_i_add_to_next_line将添加内容到前一行，并保存文件。##
# Sample: sed_i_add_to_pre_line 'sed_match_pattern' 'sed_text_to_add' /tmp/tmp.cfg
# 样例：  sed_i_add_to_pre_line 'sed_match_pattern' 'sed_text_to_add' /tmp/tmp.cfg
#############################################################################################################
function sed_i_add_to_pre_line()
{
    if [ $# -ne 3 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <sed_match_pattern> <sed_text_to_add> <file_path> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local sed_match_pattern=$1
    local sed_text_to_add=$2
    local file_path=$3

    [ ! -f "$file_path" ] && die "File [ $file_path ] is missing, please check."

    # Note: don't modify the format, beacuse the command /i (add text to next line) on aix is particular.##
    # 提示: 不要修改格式, 因为命令/i(添加文本到下一行)在Aix上比较特殊。##
    sed "/$sed_match_pattern/"'i\
'"$sed_text_to_add" $file_path >$file_path.tmp
    [ $? -ne 0 ] && die "Exec [ sed_i_add_to_pre_line '$sed_match_pattern' '$sed_text_to_add' '$file_path' ] failed."

    cat $file_path.tmp >$file_path
    rm $file_path.tmp
}

#############################################################################################################
# Read the configuration item of the configuration file.##
# 读取配置文件配置项。##
#############################################################################################################
function get_cfg_value()
{
    if [ $# -ne 2 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <cfg_file> <key> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    local cfg_file=$1
    local key=$2

    [ ! -f "$cfg_file" ] && print_error "File [ $cfg_file ] is missing, please check." && return 1

    # 1.grep搜素关键字(key前后可以有空格) 2.grep排除注释 3.awk获得值 4.sed去除前导空白 5.sed去除末尾空格##
    grep "^[[:space:]]*$key[[:space:]]*=" $cfg_file | grep -v "^[[:space:]]*#" | awk -F= '{print $2}' | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g'
    if [ $? -eq 0 ]; then
        return 0
    else
        print_error "Get value for [$key] in [$cfg_file] fail."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi
}

#############################################################################################################
# Modify the configuration item of the configuration file.##
# 修改配置文件配置项。##
#############################################################################################################
function set_cfg_value()
{
    if [ $# -ne 3 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <cfg_file> <key> <new_value> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local cfg_file=$1
    local key=$2
    local new_value=$3

    [ ! -f "$cfg_file" ] && die "File [ $cfg_file ] is missing, please check."

    sed_i "s/^[[:space:]]*$key[[:space:]]*=.*/$key=$new_value/g" $cfg_file
    [ $? -ne 0 ] && die "Set value for [$key] in [$cfg_file] fail."

    return 0
}

#############################################################################################################
# Merge the values of the old properties to the new properties. Tested on suse, redhat, aix.##
# 合并旧Properties中的值到新Properties。在suse、redhat、aix上经过测试。##
#############################################################################################################
function update_config()
{
    if [ $# -ne 2 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <old_file> <new_file> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local old_file=$1
    local new_file=$2

    [ ! -f "$old_file" ] && die "File [ $old_file ] is missing, please check."
    [ ! -f "$new_file" ] && die "File [ $new_file ] is missing, please check."

    while read old_file_line
    do
        # Blank line##
        # 空行##
        [ -z "$old_file_line" ] && continue

        # Comment line##
        # 注释行##
        (echo $old_file_line | grep -q "^[[:space:]]*#") && continue

        local old_file_line_key=$(echo $old_file_line | awk -F= '{print $1}' | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g')
        local old_file_line_value=$(echo $old_file_line | awk -F= '{print $2}' | sed 's/^[[:space:]]*//g' | sed 's/[[:space:]]*$//g')

        set_cfg_value $new_file $old_file_line_key $old_file_line_value
    done <$old_file

    return 0
}

#############################################################################################################
# Collect process invoke stack info. Tested on suse, redhat, aix.##
# 收集脚本进程调用堆栈信息。在suse、redhat、aix上经过测试。##
#############################################################################################################
function get_process_stack_info()
{
    echo "Process info: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "==========================================================================="
    ps -f | head -n1

    pid=$$
    while [ -n "$pid" -a "$pid" -gt "0" ]
    do
        # Show process info.##
        # 显示进程信息。##
        ps -f -p $pid | tail -n1

        # Get parent process pid.##
        # 获取父进程。##
        pid=$(ps -o ppid -p $pid | tail -n1)
    done
    echo "==========================================================================="
}

#############################################################################################################
# Collect login info. Tested on suse, redhat, aix.##
# 收集登录信息。在suse、redhat、aix上经过测试。##
#############################################################################################################
function get_login_info()
{
    echo "Login info: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "==========================================================================="
    who -H
    # last | grep 'still logged in'##
    echo "==========================================================================="
}

#############################################################################################################
# Collect process invoke stack info and login info. Tested on suse, redhat, aix.##
# 收集脚本进程调用堆栈信息和登录信息。在suse、redhat、aix上经过测试。##
#############################################################################################################
function get_process_stack_info_and_login_info()
{
    get_process_stack_info
    echo

    get_login_info
    echo
    echo
}

#############################################################################################################
# Get client ip of the current terminal. Tested on suse, redhat, aix.##
# 获取当前终端的客户端IP。在suse、redhat、aix上经过测试。##
# 注意：此方法不再使用。whoami查询当前用户，who -m查询当前登录信息，如果ssh登录后有su切换用户动作，那么两种方法查询出的用户是不一致的，有必要都记录下来。##
#############################################################################################################
function get_remote_terminal()
{
    terminal=$(echo $SSH_CLIENT | awk '{print $1}')
    [ -n "$terminal" ] && echo "$terminal" && return 0

    terminal=$(who -m | cut -d\( -f2 | cut -d\) -f1)
    [ -n "$terminal" ] && echo "$terminal" && return 0

    echo "localhost"
}

#############################################################################################################
# Print operation log. Tested on suse, redhat, aix.##
# 打印操作日志。在suse、redhat、aix上经过测试。##
#############################################################################################################
function log_operation()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <operation_message> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local operation_message=$1

    local current_user=$(whoami)
    local current_ip=$(who -m | tr -s " ")
    local current_script=$(get_absolute_script_path)

    echo $(date "+%Y-%m-%d %H:%M:%S.%N" | cut -c1-23)"|$current_user|$current_ip|$current_script| $operation_message"
}

#############################################################################################################
# Print entrance operation log. Tested on suse, redhat, aix.##
# 打印入口操作日志。在suse、redhat、aix上经过测试。##
#############################################################################################################
function log_operation_start()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <operation_message> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local operation_message=$1

    log_operation "$operation_message"
    get_process_stack_info_and_login_info
}

#############################################################################################################
# Print exit operation log. Tested on suse, redhat, aix.##
# 打印出口操作日志。在suse、redhat、aix上经过测试。##
#############################################################################################################
function log_operation_end()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <operation_message> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local operation_message=$1

    log_operation "$operation_message"
}

#############################################################################################################
# Get os type.##
# 获取操作系统类型。##
#############################################################################################################
function get_os_type()
{
    if [ -f "/etc/SuSE-release" ]; then
        echo "suse"
    elif [ -f "/etc/redhat-release" ]; then
        echo "redhat"
    elif [ $(uname -s) == "AIX" ]; then
        echo "aix"
    else
        print_error "Os type is not support."
        return 1
    fi
}

#############################################################################################################
# Check whether the space remaining in the directory is sufficient. Tested on suse, redhat, aix.##
# 检查目录所在的分区剩余空间是否足够。在suse、redhat、aix上经过测试。##
#############################################################################################################
function check_space()
{
    # need_space's unit is MB.##
    # avail_space's unit is MB.##

    if [ $# -ne 2 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <check_dir> <need_space> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local check_dir=$1
    local need_space=$2

    [ ! -d "$check_dir" ] && die "Dir [ $check_dir ] is missing, please check."

    # 1.df -P: use the POSIX output format 2.AIX上的剩余大小为小数，bash不支持小数的比较，忽略小数##
    local avail_space=$(df -P -m $check_dir | tail -1 | awk '{print $(NF-2)}' | awk -F. '{print $1}')
    [ $avail_space -lt $need_space ] && die "There is not enough space in dir [ $check_dir ]. Need ${need_space}MB and available ${avail_space}MB, please check."

    return 0
}

#############################################################################################################
# Check whether the directory is empty. Tested on suse, redhat, aix.##
# 检查目录是否为空。在suse、redhat、aix上经过测试。##
#############################################################################################################
function is_dir_empty()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <check_dir> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    local check_dir=$1

    [ ! -d "$check_dir" ] && print_error "Dir [ $check_dir ] is missing, please check." && return 1

    if [ -z "$(ls -A $check_dir)" ]; then
        print_info "Dir [ $check_dir ] is empty."
        return 0
    else
        print_info "Dir [ $check_dir ] is not empty."
        return 1
    fi
}

#############################################################################################################
# Get user of a directory. Tested on suse, redhat, aix.##
# 获取目录的用户。在suse、redhat、aix上经过测试。##
#############################################################################################################
function get_dir_user_name()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <dir> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    local dir=$1

    [ ! -d "$dir" ] && print_error "Dir [ $dir ] is missing, please check." && return 1

    ls -l -d $dir | awk '{print $3}'
    if [ $? -eq 0 ]; then
        return 0
    else
        print_error "Get dir [ $dir ] user name fail."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi
}

#############################################################################################################
# Get user group of a directory. Tested on suse, redhat, aix.##
# 获取目录的用户组。在suse、redhat、aix上经过测试。##
#############################################################################################################
function get_dir_group_name()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <dir> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    local dir=$1

    [ ! -d "$dir" ] && print_error "Dir [ $dir ] is missing, please check." && return 1

    ls -l -d $dir | awk '{print $4}'
    if [ $? -eq 0 ]; then
        return 0
    else
        print_error "Get dir [ $dir ] group name fail."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi
}

#############################################################################################################
# Modify files and directorys permissions. Tested on suse, redhat, aix.##
# 修改文件和目录权限。在suse、redhat、aix上经过测试。##
# Sample: chmod_all_files_and_dirs $APP_HOME 700 600 700 $APP_HOME/jre $APP_HOME/work
# 样例：  chmod_all_files_and_dirs $APP_HOME 700 600 700 $APP_HOME/jre $APP_HOME/work
#############################################################################################################
function chmod_all_files_and_dirs()
{
    if [ $# -lt 4 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <dir> <dir_mod> <file_mod> <exec_file_mod> [exclude_sub_dirs ...] ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local dir=$1
    local dir_mod=$2
    local file_mod=$3
    local exec_file_mod=$4
    shift 1
    shift 1
    shift 1
    shift 1
    local exclude_sub_dirs="$*"

    [ ! -d "$dir" ] && die "Dir [ $dir ] is missing, please check."

    # Modify all directories permission.##
    for dir_path in $(find $dir -type d -name "*")
    do
        local is_dir_path_in_exclude_sub_dirs=false
        for exclude_sub_dir in $exclude_sub_dirs
        do
            if [[ "$dir_path/" =~ $exclude_sub_dir/.* ]]; then
                local is_dir_path_in_exclude_sub_dirs=true
                break
            fi
        done
        [ "$is_dir_path_in_exclude_sub_dirs" == "true" ] && print_info "Skip to chmod dir [ $dir_path ]." && continue

        chmod $dir_mod $dir_path
        print_info "Chmod dir [ $dir_path ] to $dir_mod."
    done

    # Modify all files permission.##
    for file_path in $(find $dir -type f -name "*")
    do
        local is_file_path_in_exclude_sub_dirs=false
        for exclude_sub_dir in $exclude_sub_dirs
        do
            if [[ "$file_path" =~ $exclude_sub_dir/.* ]]; then
                local is_file_path_in_exclude_sub_dirs=true
                break
            fi
        done
        [ "$is_file_path_in_exclude_sub_dirs" == "true" ] && print_info "Skip to chmod file [ $file_path ]." && continue

        if [[ "$file_path" =~ .*\.sh$ ]] || [[ "$file_path" =~ .*\.exp$ ]] || [[ "$file_path" =~ .*\.pyc$ ]] || [[ "$file_path" =~ .*\.py$ ]]; then
            # The file name is with given extension. such as ".sh", ".exp" and so on.##
            chmod $exec_file_mod $file_path
            print_info "Chmod given extension file [ $file_path ] to $exec_file_mod."
        elif [ -n "$(file $file_path | grep 'shell script')" ]; then
            # The first line of file is like "#!/bin/bash".##
            chmod $exec_file_mod $file_path
            print_info "Chmod script file [ $file_path ] to $exec_file_mod."
        elif [ -n "$(file $file_path | grep 'executable' | grep -e 'LSB' -e 'RISC')" ]; then
            # The binary executable file.##
            chmod $exec_file_mod $file_path
            print_info "Chmod binary executable file [ $file_path ] to $exec_file_mod."
        else
            # other file.##
            chmod $file_mod $file_path
            print_info "Chmod file [ $file_path ] to $file_mod."
        fi
    done

    return 0
}

#############################################################################################################
# Check whether String1 is a substring of string2. Tested on suse, redhat, aix.##
# 字符串1是否为字符串2的子串。在suse、redhat、aix上经过测试。##
#############################################################################################################
function is_substring()
{
    if [ $# -ne 2 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <string> <substring> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    local string=$1
    local substring=$2

    if [[ "$string" == *$substring* ]]; then
        print_info "String [ $string ] contains string [ $substring ]."
        return 0
    else
        print_info "String [ $string ] does not contains string [ $substring ]."
        return 1
    fi
}

#############################################################################################################
# Check whether port is available. Tested on suse, redhat, aix.##
# 检查端口是否可用。在suse、redhat、aix上经过测试。##
#############################################################################################################
function check_port_available()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <check_port> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local check_port=$1

    # Cmd 'lsof' is not installed by default on aix.##
    # Ip and port delimiter on suse is ':'. (netstat -an | grep 8000 --> 127.0.0.1:8000)
    # Ip and port delimiter on aix  is '.'. (netstat -an | grep 8000 --> 127.0.0.1.8000)
    netstat -an | grep -q "[.:]${check_port}[[:space:]]"
    [ $? -eq 0 ] && die "Port [ $check_port ] have been occupied, please stop the progress that occupies the port."

    return 0
}

#############################################################################################################
# Check whether IP is legal. Tested on suse, redhat, aix.##
# 检查IP是否合法。在suse、redhat、aix上经过测试。##
#############################################################################################################
function check_ip_legal()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <check_ip> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local check_ip=$1

    echo $check_ip | grep -q -E "^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$"
    [ $? -ne 0 ] && die "IP [ $check_ip ] is not legal."

    return 0
}

#############################################################################################################
# Convert IP to decimal number. Tested on suse, redhat, aix.##
# 转化IP为10进制数字。在suse、redhat、aix上经过测试。##
#############################################################################################################
function ip_to_dec()
{
    # IP to Decimal：##
    # echo "1.2.3.4" | awk -F '.' '{printf "%d\n", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}'##
    # IP to Hexadecimal：##
    # echo "1.2.3.4" | awk -F '.' '{printf "%x\n", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}'##

    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <ip> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi

    local ip=$1

    check_ip_legal $ip

    echo "$ip" | awk -F '.' '{printf "%d\n", ($1 * 2^24) + ($2 * 2^16) + ($3 * 2^8) + $4}'
    if [ $? -eq 0 ]; then
        return 0
    else
        print_error "Convert IP [ $ip ] to decimal number fail."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        return 1
    fi
}

#############################################################################################################
# Check whether two IP is in the same network segment. Tested on suse, redhat, aix.##
# 判断两个IP是否为相同网段。在suse、redhat、aix上经过测试。##
#############################################################################################################
function is_same_subnet()
{
    if [ $# -ne 4 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <ip1> <mask1> <ip2> <mask2> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local ip1=$1
    local mask1=$2
    local ip2=$3
    local mask2=$4

    check_ip_legal $ip1
    check_ip_legal $mask1
    check_ip_legal $ip2
    check_ip_legal $mask2

    local ip1_dec=$(ip_to_dec $ip1)
    local mask1_dec=$(ip_to_dec $mask1)
    local ip2_dec=$(ip_to_dec $ip2)
    local mask2_dec=$(ip_to_dec $mask2)

    local network1=$(($ip1_dec & $mask1_dec))
    local network2=$(($ip2_dec & $mask2_dec))

    [ "$network1" != "$network2" ] && die "Ip/Mask [ $ip1/$mask1 ] and Ip/Mask [ $ip2/$mask2 ] is not in the same network segment."

    return 0
}

#############################################################################################################
# Test network connectivity. Tested on suse, redhat, aix.##
# 测试网络连通性。在suse、redhat、aix上经过测试。##
#############################################################################################################
function test_network_connectivity()
{
    if [ $# -eq 1 ]; then
        local remote_ip=$1
        local timeout=1
    elif [ $# -eq 2 ]; then
        local remote_ip=$1
        local timeout=$2
    else
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <remote_ip> [timeout] ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    print_info "Test network connectivity of remote ip [ $remote_ip ] start."

    local os_type=$(uname)
    case "$os_type" in
        AIX)
            local ping_cmd="ping -c 3 $remote_ip"
            ;;
        Linux)
            local ping_cmd="ping -c 3 -i 0.2 -w $timeout $remote_ip"
            ;;
        *)
            die "Not support operating system [ $os_type ]. Support operating system types [ AIX Linux ]."
            ;;
    esac

    $ping_cmd >/dev/null 2>&1
    [ $? -ne 0 ] && die "Host [ $remote_ip ] could not be reached. Please check the network."

    print_info "Test network connectivity of remote ip [ $remote_ip ] finish."
}

#############################################################################################################
# Extract compressed file. Tested on suse, redhat, aix.##
# 解压压缩文件。在suse、redhat、aix上经过测试。##
#############################################################################################################
function uncompress_pkg()
{
    if [ $# -eq 1 ]; then
        local pkg_name=$1
        local target_dir=./
    elif [ $# -eq 2 ]; then
        local pkg_name=$1
        local target_dir=$2
    else
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <pkg_name> [target_dir] ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    [ ! -f "$pkg_name" ] && die "File [ $pkg_name ] is missing, please check."

    if [ -n "$(echo $pkg_name | grep '\.tar\.gz$')" ] || [ -n "$(echo $pkg_name | grep '\.tgz$')" ]; then
        # .tar.gz .tgz##
        mkdir -p $target_dir
        gzip -dc $pkg_name | (cd $target_dir && tar -xvf -)
        [ $? -ne 0 ] && die "Uncompress pkg [ $pkg_name ] to dir [ $target_dir ] failed."
    elif [ -n "$(echo $pkg_name | grep '\.tar\.bz2$')" ]; then
        # .tar.bz2##
        mkdir -p $target_dir
        bzip2 -dc $pkg_name | (cd $target_dir && tar -xvf -)
        [ $? -ne 0 ] && die "Uncompress pkg [ $pkg_name ] to dir [ $target_dir ] failed."
    elif [ -n "$(echo $pkg_name | grep '\.zip$')" ]; then
        # .zip##
        unzip -o -q $pkg_name -d $target_dir
        [ $? -ne 0 ] && die "Uncompress pkg [ $pkg_name ] to dir [ $target_dir ] failed."
    else
        die "Not support compress pkg [ $pkg_name ]. Support compress pkg types [ .tar.gz .tgz .tar.bz2 .zip ]."
    fi

    return 0
}

#############################################################################################################
# Check whether the user's password expired. Tested on suse, redhat, aix.##
# 检查用户的密码是否过期。在suse、redhat、aix上经过测试。##
#############################################################################################################
function check_password_expired()
{
    if [ $# -ne 1 ]; then
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <username> ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    local username=$1

    id $username >/dev/null 2>&1
    [ $? -ne 0 ] && die "User [ $username ] does not exist."

    if [ $(uname -s) == "AIX" ]; then
        local current_day=$(date "+%Y%m%d" | cut -c 3-8)

        # format: expire_time (MMDDhhmmYY)##
        local expire_time=$(lsuser $username | awk -F"expires=" '{print $2}' | awk '{print $1}')
        [ "$expire_time" -eq 0 ] && return 0

        local year=$(echo $expire_time | cut -c 9-10)
        local month=$(echo $expire_time | cut -c 1-2)
        local day=$(echo $expire_time | cut -c 3-4)
        local expire_day="$year$month$day"

        [ "$expire_day" -lt "$current_day" ] && die "Password of user [ $username ] has expired."
    else
        local current_day=$(($(date +"%s") / $((60 * 60 * 24))))

        local changed_day=$(awk -F: "/^$username:/{print \$3}" /etc/shadow)
        local max_day=$(awk -F: "/^$username:/{print \$5}" /etc/shadow)
        [ -z "$max_day" ] && return 0

        [[ "$(($changed_day + $max_day - $current_day))" -lt 0 ]] && die "Password of user [ $username ] has expired."
    fi

    return 0
}

#############################################################################################################
# Roll file. Tested on suse, redhat, aix.##
# 滚动文件。在suse、redhat、aix上经过测试。##
#############################################################################################################
function file_rotate()
{
    # limit_size's unit is MB.##

    if [ $# -eq 1 ]; then
        local file_path=$1
        local limit_count=10
        local limit_size=-1
    elif [ $# -eq 2 ]; then
        local file_path=$1
        local limit_count=$2
        local limit_size=-1
    elif [ $# -eq 3 ]; then
        local file_path=$1
        local limit_count=$2
        local limit_size=$3
    else
        print_error "Args error:      [ $FUNCNAME $* ]."
        print_error "Usage:           [ $FUNCNAME <file_path> [limit_count] [limit_size] ]."
        print_error "Bash stack info: [ $(get_bash_stack_info) ]."
        exit 1
    fi

    [ ! -f "$file_path" ] && return 0

    local file_size=$(($(ls -l $file_path | awk '{print $5}') / 1024 / 1024))
    [ "$limit_size" -ne "-1" ] && [ "$file_size" -le "$limit_size" ] && return 0

    local file_dir=$(dirname $file_path)
    local file_name=$(basename $file_path)
    local backup_file_name=$file_name.bak.at.$(date +%Y%m%d-%H%M%S).random.$RANDOM

    cd $file_dir
    # Reconfirm if file exists.##
    # 重新确认文件是否存在。##
    [ ! -f "$file_name" ] && return 0
    mv $file_name $backup_file_name
    zip $backup_file_name.zip $backup_file_name >/dev/null 2>&1
    rm $backup_file_name
    cd - >/dev/null 2>&1

    local files_to_delete=$(find $file_dir -name "$file_name.bak.at.*.zip" | sort -r | sed "1,${limit_count}d")
    [ -n "$files_to_delete" ] && print_info "Delete backup files [ $files_to_delete ]."
    [ -n "$files_to_delete" ] && rm $files_to_delete

    return 0
}

# Initialize the public environment variables.##
# 初始化公用环境变量。##
# Use curly braces {} surrounded and redirect the output, to avoid to print too much useless debugging information. Other similar code is the same role, not comment any more.##
# 使用大括号{}包围起来，并重定向输出，避免打印过多无用的调试信息。其他的类似的代码作用相同，不一一注释。##
# Pay attention to use {} and (), {} execute commands in the current process, () will open new child process to execute the command.##
# 注意使用{}和()不同，{}在当前进程中执行命令，()会新开启子进程执行命令。##
{
    # Set the bash debug info style to pretty format. +[T: <Time>, L: <LineNumber>, S: <ScriptName>, F: <Function>]##
    # 设置bash的调试信息为漂亮的格式。+[T: <Time>, L: <LineNumber>, S: <ScriptName>, F: <Function>]##
    [ -c /dev/stdout ] && export PS4_COLOR="32"
    [ ! -c /dev/stdout ] && export PS4_COLOR=""
    export PS4='+[$(debug_info=$(printf "T: %s, L:%3s, S: %s, F: %s" "$(date +%H%M%S)" "$LINENO" "$(basename $(cd $(dirname ${BASH_SOURCE[0]}) && pwd))/$(basename ${BASH_SOURCE[0]})" "$(for ((i=${#FUNCNAME[*]}-1; i>=0; i--)) do func_stack="$func_stack ${FUNCNAME[i]}"; done; echo $func_stack)") ; [ -z "$PS4_COLOR" ] && echo ${debug_info:0:94} ; [ -n "$PS4_COLOR" ] && echo -e "\e[${PS4_COLOR}m${debug_info:0:80}\e[0m")]: '

    # Record the current debug state.##
    # 记录当前调试状态。##
    export setx=$(debug_state_query)

    # Record comm_lib.sh's absolute path.##
    # 记录本类库脚本的绝对路径。##
    export comm_lib_dir=$(dirname $(get_absolute_script_path ${BASH_SOURCE[0]}))

    # Capture and output all the error messages.##
    # 捕获并输出所有的错误信息。##
    # Uncomment to enable error_trap.##
    # 去掉注释可以使error_trap生效。##
    # trap '(error_trap $BASH_SOURCE $LINENO $?) 2>/dev/null || exit 1' ERR  # 打印错误后退出。##
    trap '(error_trap $BASH_SOURCE $LINENO $?) 2>/dev/null' ERR              # 打印错误后不退出。##

    # Single-step debugging a script.##
    # 单步调试某脚本。##
    # Uncomment to enable debug_trap.##
    # 去掉注释可以使debug_trap生效。##
    # trap '(debug_trap $BASH_SOURCE $LINENO) 2>/dev/null' DEBUG
} >/dev/null 2>&1
