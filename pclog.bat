@echo off
chcp 65001 >nul
if "%~2"=="" (
	setlocal enableDelayedExpansion
	goto main
)

:main
	if "%~1" == "" (
        echo=
        set a="将 logcat 打出的日志文件通过 PID 对日志进行分类，且尽量生成一个"
        echo !a!
        set b="PID 与程序名的映射列表(pid_proces.txt), 指出 PID 与程序名的对应"
        echo !b!
        set c="关系。生成的结果放在日志文件所在目录的 log_divided_by_pid 目录内。"
        echo !c!
        echo=
        echo pclog  ^<log file^>
        echo log file       日志文件
        echo=
        echo 例:
        echo pclog  logname.log
        goto eof
    )
    set file=%~1
    if exist ".\log_divided_by_pid" (
        rd /s /q ".\log_divided_by_pid"
    )
    md ".\log_divided_by_pid"
    echo 日志处理中...
    for /f "delims=`" %%x in (!file!) do (
        for /f "tokens=3,6,7,8,9" %%i in ("%%x") do (
            echo %%x 1>> ".\log_divided_by_pid\%%i.log"
            if "%%j"=="ActivityManager:" (
                if "%%k"=="Start" (
                    if "%%l"=="proc" (
                        echo %%m >> ".\log_divided_by_pid\pid_proces.txt"
                    )
                )
            )
        )
    )
    echo 日志处理完成!
goto eof

:eof