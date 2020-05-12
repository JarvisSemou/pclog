# **pclog**

---

pclog (Process log) 可以将 logcat 打出的日志文件通过 PID 对日志进行分类，且尽量生成一个 PID 与程序名的映射列表(pid_proces.txt), 指出 PID 与程序名的对应关系。生成的结果默认放在日志文件所在目录的 log_divided_by_pid 目录内。  

注意：文件名和目录名不要包含特殊字符，否则脚本会出错，建议只用字母、数字和下划线！

## 使用方式

```text
pclog  <log file>  [target folder]

    log file       日志文件
    target folder  目标输出文件夹( 默认为 log_divided_by_pid )
  
    例:
    pclog  logname.log             处理 logname.log 文件
    pclog  logname.log    target   处理 logname.log 文件并将结果放到 target 目录
```

pid_proces.txt 文件的内容格式

```text
pid:process_name/user_name

进程pid:进程名/进程用户名

例：
1339:com.android.systemui/u0a19

pid：1339
进程名：com.android.systemui
进程用户名：u0a19
```
