# Bash通用类库

![kiwi and kiwi bird](images/kiwi_and_kiwi_bird.png)  

## 简介

Bash通用类库，支持打印详细的调试信息，支持脚本异常退出时打印调用堆栈等功能。  

## 功能

| 函数                                    | 说明                                 | 可见性 |
| --------------------------------------- | ------------------------------------ | ------ |
| echo_to_stderr()                        | 重定向stdout到stderr                 | 私有   |
| echo_red()                              | 输出红色文字                         | 公开   |
| echo_green()                            | 输出绿色文字                         | 公开   |
| echo_yellow()                           | 输出黄色文字                         | 公开   |
| echo_blue()                             | 输出蓝色文字                         | 公开   |
| print_error()                           | 输出错误信息到屏幕和日志             | 公开   |
| print_info()                            | 输出信息到屏幕和日志                 | 公开   |
| log_error()                             | 输出错误信息到日志                   | 公开   |
| log_info()                              | 输出信息到日志                       | 公开   |
| die()                                   | 输出错误信息到屏幕和日志并退出       | 公开   |
| get_bash_stack_info()                   | 获取bash调用的堆栈信息               | 私有   |
| get_absolute_script_path()              | 获取脚本的绝对路径                   | 私有   |
| debug_state_query()                     | 查询脚本的调试状态                   | 私有   |
| debug_state_close()                     | 关闭脚本的调试状态                   | 公开   |
| debug_state_resume()                    | 恢复脚本的调试状态                   | 公开   |
| error_trap()                            | 错误陷阱                             | 私有   |
| debug_trap()                            | 调试陷阱                             | 私有   |
| sed_i()                                 | sed -i的通用实现                     | 公开   |
| sed_i_add_to_next_line()                | 在匹配行的下一行添加文本             | 公开   |
| sed_i_add_to_pre_line()                 | 在匹配行的前一行添加文本             | 公开   |
| get_cfg_value()                         | 读取配置文件配置项                   | 公开   |
| set_cfg_value()                         | 修改配置文件配置项                   | 公开   |
| update_config()                         | 合并旧Properties中的值到新Properties | 公开   |
| get_process_stack_info_and_login_info() | 收集脚本进程调用堆栈信息和登录信息   | 私有   |
| get_remote_terminal()                   | 获取当前终端的客户端IP               | 私有   |
| log_operation()                         | 打印操作日志                         | 私有   |
| log_operation_start()                   | 打印入口操作日志                     | 公开   |
| log_operation_end()                     | 打印出口操作日志                     | 公开   |
| get_os_type()                           | 获取操作系统类型                     | 公开   |
| check_space()                           | 检查目录所在的分区剩余空间是否足够   | 公开   |
| is_dir_empty()                          | 检查目录是否为空                     | 公开   |
| get_dir_user_name()                     | 获取目录的用户                       | 公开   |
| get_dir_group_name()                    | 获取目录的用户组                     | 公开   |
| chmod_all_files_and_dirs()              | 修改文件和目录权限                   | 公开   |
| is_substring()                          | 字符串1是否为字符串2的子串           | 公开   |
| check_port_available()                  | 检查端口是否可用                     | 公开   |
| check_ip_legal()                        | 检查IP是否合法                       | 公开   |
| ip_to_dec()                             | 转化IP为10进制数字                   | 公开   |
| is_same_subnet()                        | 判断两个IP是否为相同网段             | 公开   |
| test_network_connectivity()             | 测试网络连通性                       | 公开   |
| uncompress_pkg()                        | 解压压缩文件                         | 公开   |
| check_password_expired()                | 检查用户的密码是否过期               | 公开   |
| file_rotate()                           | 滚动文件                             | 公开   |

> 可见性说明：  
> 公开: 对外公开，供外部脚本调用。  
> 私有: 框架私有，内部调用，不保证其完全通用及有效。  
> 废弃: 废弃方法，后续版本中可能会被移除，不保证其完全通用及有效。  

## 捐赠

如果你觉得Kiwi对你有帮助，或者想对我微小工作的一点资瓷，欢迎给我捐赠。  

<img src="images/qrcode_alipay.jpg"><img src="images/qrcode_wechat.jpg">  
