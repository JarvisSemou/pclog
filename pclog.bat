@echo off
@rem version: v1.1
@rem author: Jarvis Semou
@rem date: 2020.5.16
if "!RUN_ONCE!" neq "%RUN_ONCE%" (
    set DEBUG=false
    chcp 65001 >nul
    setlocal enableDelayedExpansion
    goto initStaticValue
)
:methodBrach
    if "%~2"=="showHelpMessage" goto showHelpMessage 
    if "%~2"=="resoleLogType" goto resoleLogType
    if "%~2"=="bihuan" goto bihuan
    if "%~2"=="zdevice" goto zdevice
    if "!DEBUG!"=="true" echo 方法 "%~2" 不存在 
goto eof

:initStaticValue
    @rem 要解析的日志类型
    set array_log_types=null
    @rem 源 logcat 日志文件
    set file=null
    @rem 目标输出文件夹
    set targetFolder=log_divided_by_pid
goto main

:main
    @rem 解析参数
	if "%~1" == "" (
        @rem 无输入参数
        call %~n0 void showHelpMessage
        goto eof
    ) 
    if "%~1"=="-t" (
        if "%~2" neq "" (
            if "%~4" neq "" (
                @rem pclog -t bihuan logname.log target
                set targetFolder=%~4
            )
            @rem pclog -t bihuan logname.log
            call %~n0 void resoleLogType "%~2"
            set file=%~3
        ) else (
            @rem 错误的输入参数
            @rem pclog -t
            call %~n0 void showHelpMessage
            goto eof
        )
    ) else (
        if "%~2" neq "" (
            @rem pclog  logname.log target
            set targetFolder=%~2
        ) 
        @rem pclog  logname.log
        set file=%~1
    )
    @rem 删除旧日志
    if exist "%~dp0!targetFolder!" (
        rd /s /q "%~dp0!targetFolder!"
    )
    md "%~dp0!targetFolder!"
    echo 日志处理中...
    for %%t in ("!targetFolder!") do (
        @rem 按 PID 划分日志
        echo pid^:process_name^/user_name >> "%%~ft\pid_proces.txt"
        echo ------------------------------------------ >> "%%~ft\pid_proces.txt"
        for /f "usebackq delims=`" %%x in ("!file!") do (
            for /f "tokens=3,6,7,8,9" %%i in ("%%x") do (
                echo %%x 1>> "%%~ft\%%i.log"
                if "%%j"=="ActivityManager:" (
                    if "%%k"=="Start" (
                        if "%%l"=="proc" (
                            echo %%m 1>> "%%~ft\pid_proces.txt"
                        )
                    )
                )
            )
        )
        @rem 进行特定程序的日志筛选
        if "!array_log_types!" neq "null" (
            for %%i in (!array_log_types!) do (
                call %~n0 void %%~i "%%~ft"
            )
        )
    )
    echo 日志处理完成!
goto eof

@rem 解析 -t 开关的参数，将解析出的日志类型添加到 array_log_types
@rem 
@rem return void
@rem param_3 string -t 开关的参数
:resoleLogType
    set result=null
    for %%i in (%~3) do (
        if "!result!" neq "null" (
            set result=!result!,"%%~i"
        ) else (
            set result="%%~i"
        )
    )
    set array_log_types=!result!
goto eof

@rem 筛选闭环协议日志
@rem
@rem param_3 string 目标输出文件夹
@rem return void
:bihuan
    for /f "usebackq delims=`" %%l in ("!file!") do (
        for /f "tokens=1,2,3,4,5,6 delims=:" %%o in ("%%l") do (
            set isIt=false
            for /f "tokens=2" %%x in ("%%s") do (
                if "%%x"=="SEND" (
                    set isIt=true
                )
                if "%%x"=="RECEIVE" (
                    set isIt=true
                )
            )
            if "!isIt!"=="true" (
                echo %%l 1>>"%~f3\闭环程序日志.log"
            )
        )
    )
goto eof

@rem 筛选 zdevice 日志
@rem
@rem param_3 string 目标输出文件夹
@rem return void
:zdevice
    for /f "delims=`" %%l in ('findstr  /r /c:".* [VIWDE] zdevice : .*" "!file!"') do (
        echo %%~l 1>>"%~f3\zdevice日志.log"
    )
goto eof

@rem 显示命令的帮助信息
@rem
@rem return void
:showHelpMessage
    echo=
    set a=将 logcat 打出的日志文件通过 PID 对日志进行分类，且尽量生成一个
    echo !a!
    set b=PID 与程序名的映射列表^(pid_proces.txt^), 指出 PID 与程序名的对应
    echo !b!
    set c=关系。生成的结果默认放在日志文件所在目录的 log_divided_by_pid 目录内。
    echo !c!
    set d=注意：文件名和目录名不要包含特殊字符，否则脚本会出错，建议只用字母、数字和下划线！
    echo !d!
    echo=
    echo pclog ^[^-t ^"^<log type^,^.^.^.^,log types^>^"^] ^<log file^>    ^[target folder^]
    echo=
    echo ^-t ^"^<log type^>^"  日志类型
    echo log file       日志文件
    echo target folder  目标输出文件夹^(默认为 log_divided_by_pid ^)
    echo=
    echo 例:
    echo pclog  logname.log                  处理 logname.log 文件
    echo pclog  logname.log    target        处理 logname.log 文件并将结果放到 target 目录
    echo pclog ^-t ^"bihuan,zdevice^" logname.log target 
    echo                                     处理 logname.log 文件，并提取其中的闭环程序和
    echo                                      zdevice 日志，将结果放到 target 目录
    echo=
    echo 目前支持单独筛选的日志类型
    echo ---------------------------------
    echo ^|  日志类型    ^|  对应程序      ^|
    echo ---------------------------------
    echo ^|  bihuan      ^|  闭环          ^|
    echo ---------------------------------
    echo ^|  zdevice     ^|  zdevice       ^|
    echo ---------------------------------
goto eof

:eof