@echo off
rem version: v1.0
rem author: Jarvis Semou
rem date: 2020.5.11
chcp 65001 >nul
rem if "%~2"=="" (
rem	setlocal enableDelayedExpansion
rem	goto main
rem )
setlocal enableDelayedExpansion
goto main

:main
	if "%~1" == "" (
        echo=
        set a="将 logcat 打出的日志文件通过 PID 对日志进行分类，且尽量生成一个"
        echo !a!
        set b="PID 与程序名的映射列表(pid_proces.txt), 指出 PID 与程序名的对应"
        echo !b!
        set c="关系。生成的结果默认放在日志文件所在目录的 log_divided_by_pid 目录内。"
        echo !c!
        set d="注意：文件名和目录名不要包含特殊字符，否则脚本会出错，建议只用英文、数字和下划线！"
        echo !d!
        echo=
        echo pclog  ^<log file^>    ^[target folder^]
        echo log file       日志文件
        echo target folder  目标输出文件夹^(默认为 log_divided_by_pid ^)
        echo=
        echo 例:
        echo pclog  logname.log             处理 logname.log 文件
        echo pclog  logname.log    target   处理 logname.log 文件并将结果放到 target 目录
        goto eof
    )
    set file=%~1
    set targetFolder=".\log_divided_by_pid"
    if "%~2" neq "" set targetFolder=%~2
    if exist "!targetFolder!" (
        rd /s /q "!targetFolder!"
    )
    md "!targetFolder!"
    echo 日志处理中...
    for %%t in ("!targetFolder!") do (
        for /f "usebackq delims=`" %%x in ("!file!") do (
            for /f "tokens=3,6,7,8,9" %%i in ("%%x") do (
                echo %%x 1>> "%%~ft\%%i.log"
                if "%%j"=="ActivityManager:" (
                    if "%%k"=="Start" (
                        if "%%l"=="proc" (
                            echo %%m >> "%%~ft\pid_proces.txt"
                        )
                    )
                )
            )
        )
    )
    echo 日志处理完成!
goto eof

:eof