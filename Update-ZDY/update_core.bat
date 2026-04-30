@echo off

:: ===== ТОЧКА ВХОДА =====
if "%~1"=="status_strategy" goto :status_strategy
if "%~1"=="get_strategy" goto :get_strategy
if "%~1"=="remove" goto :service_remove
if "%~1"=="install" goto :service_install_by_name
if "%~1"=="load_user_lists" goto :load_user_lists
exit /b


:: ===== STATUS_STRATEGY =====
:status_strategy
setlocal EnableDelayedExpansion
set "ServiceStatus="
for /f "tokens=3 delims=: " %%A in ('sc query "zapret" 2^>nul ^| findstr /i "STATE"') do set "ServiceStatus=%%A"
set "ServiceStatus=!ServiceStatus: =!"
if /i "!ServiceStatus!"=="RUNNING" exit /b 1
endlocal
exit /b 0


:: ===== GET_STRATEGY =====
:get_strategy
setlocal EnableDelayedExpansion
set "strategy="
for /f "tokens=2*" %%A in ('reg query "HKLM\System\CurrentControlSet\Services\zapret" /v zapret-discord-youtube 2^>nul ^| findstr /i "zapret-discord-youtube"') do (
    set "strategy=%%B"
)
if defined strategy echo !strategy!
endlocal
exit /b 0


:: ===== INSTALL BY NAME =====
:service_install_by_name
setlocal EnableDelayedExpansion
if "%~2"=="" (
    echo [ERROR] Не указано имя стратегии
    exit /b 1
)
set "selectedFile=%~2"
if /i "!selectedFile:~-4!" neq ".bat" set "selectedFile=!selectedFile!.bat"
if not exist "%~dp0!selectedFile!" (
    echo [ERROR] Файл стратегии !selectedFile! не найден
    exit /b 1
)
cd /d "%~dp0"
set "BIN_PATH=%~dp0bin\"
set "LISTS_PATH=%~dp0lists\"
call :game_switch_status
set "args_with_value=sni host altorder"
set "args="
set "capture=0"
set "mergeargs=0"
set QUOTE="
for /f "tokens=*" %%a in ('type "!selectedFile!"') do (
    set "line=%%a"
    call set "line=%%line:^!=EXCL_MARK%%"
    echo !line! | findstr /i "%BIN%winws.exe" >nul
    if not errorlevel 1 set "capture=1"
    if !capture!==1 (
        if not defined args set "line=!line:*%BIN%winws.exe"=!"
        set "temp_args="
        for %%i in (!line!) do (
            set "arg=%%i"
            if not "!arg!"=="^" (
                if "!arg:~0,2!" EQU "--" if not !mergeargs!==0 set "mergeargs=0"
                if "!arg:~0,1!" EQU "!QUOTE!" (
                    set "arg=!arg:~1,-1!"
                    echo !arg! | findstr ":" >nul
                    if !errorlevel!==0 (
                        set "arg=\!QUOTE!!arg!\!QUOTE!"
                    ) else if "!arg:~0,1!"=="@" (
                        set "arg=\!QUOTE!@%~dp0!arg:~1!\!QUOTE!"
                    ) else if "!arg:~0,5!"=="%%BIN%%" (
                        set "arg=\!QUOTE!!BIN_PATH!!arg:~5!\!QUOTE!"
                    ) else if "!arg:~0,7!"=="%%LISTS%%" (
                        set "arg=\!QUOTE!!LISTS_PATH!!arg:~7!\!QUOTE!"
                    ) else (
                        set "arg=\!QUOTE!%~dp0!arg!\!QUOTE!"
                    )
                ) else if "!arg:~0,12!" EQU "%%GameFilter%%" (
                    set "arg=!GameFilter!"
                ) else if "!arg:~0,15!" EQU "%%GameFilterTCP%%" (
                    set "arg=!GameFilterTCP!"
                ) else if "!arg:~0,15!" EQU "%%GameFilterUDP%%" (
                    set "arg=!GameFilterUDP!"
                )
                if !mergeargs!==1 (
                    set "temp_args=!temp_args!,!arg!"
                ) else if !mergeargs!==3 (
                    set "temp_args=!temp_args!=!arg!"
                    set "mergeargs=1"
                ) else (
                    set "temp_args=!temp_args! !arg!"
                )
                if "!arg:~0,2!" EQU "--" (
                    set "mergeargs=2"
                ) else if !mergeargs! GEQ 1 (
                    if !mergeargs!==2 set "mergeargs=1"
                    for %%x in (!args_with_value!) do if /i "%%x"=="!arg!" set "mergeargs=3"
                )
            )
        )
        if not "!temp_args!"=="" set "args=!args! !temp_args!"
    )
)
call :tcp_enable
set ARGS=%args%
call set "ARGS=%%ARGS:EXCL_MARK=^!%%"
echo [INFO] Installing service...
set SRVCNAME=zapret
net stop %SRVCNAME% >nul 2>&1
sc delete %SRVCNAME% >nul 2>&1
timeout /t 2 /nobreak >nul
sc create %SRVCNAME% binPath= "\"%BIN_PATH%winws.exe\" !ARGS!" DisplayName= "zapret" start= auto
sc description %SRVCNAME% "Zapret DPI bypass software"
sc start %SRVCNAME%
timeout /t 3 /nobreak >nul
sc query "%SRVCNAME%" | findstr /i "RUNNING" >nul
if !errorlevel!==0 (
    echo [OK] Service is RUNNING
) else (
    echo [WARN] Service may have failed to start, checking...
    sc query "%SRVCNAME%"
)
for %%F in ("!selectedFile!") do set "filename=%%~nF"
reg add "HKLM\System\CurrentControlSet\Services\zapret" /v zapret-discord-youtube /t REG_SZ /d "!filename!" /f
echo [OK] Service installed with strategy: !selectedFile!
endlocal
exit /b 0


:: ===== REMOVE =====
:service_remove
setlocal EnableDelayedExpansion
set SRVCNAME=zapret
sc query "!SRVCNAME!" >nul 2>&1
if !errorlevel!==0 (
    net stop %SRVCNAME%
    sc delete %SRVCNAME%
    echo [OK] Service removed
) else (
    echo [INFO] Service was not installed
)
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if !errorlevel!==0 taskkill /IM winws.exe /F > nul
sc query "WinDivert" >nul 2>&1
if !errorlevel!==0 (
    net stop "WinDivert"
    sc query "WinDivert" >nul 2>&1
    if !errorlevel!==0 sc delete "WinDivert"
)
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
endlocal
exit /b 0


:: ===== LOAD USER LISTS =====
:load_user_lists
set "LISTS_PATH=%~dp0lists\"
if not exist "%LISTS_PATH%ipset-exclude-user.txt" echo 203.0.113.113/32>"%LISTS_PATH%ipset-exclude-user.txt"
if not exist "%LISTS_PATH%list-general-user.txt" echo domain.example.abc>"%LISTS_PATH%list-general-user.txt"
if not exist "%LISTS_PATH%list-exclude-user.txt" echo domain.example.abc>"%LISTS_PATH%list-exclude-user.txt"
exit /b


:: ===== TCP ENABLE =====
:tcp_enable
netsh interface tcp show global | findstr /i "timestamps" | findstr /i "enabled" > nul || netsh interface tcp set global timestamps=enabled > nul 2>&1
exit /b


:: ===== GAME SWITCH STATUS =====
:game_switch_status
set "gameFlagFile=%~dp0utils\game_filter.enabled"
if not exist "%gameFlagFile%" (
    set "GameFilter=12"
    set "GameFilterTCP=12"
    set "GameFilterUDP=12"
    exit /b
)
set "GameFilterMode="
for /f "usebackq delims=" %%A in ("%gameFlagFile%") do if not defined GameFilterMode set "GameFilterMode=%%A"
if /i "%GameFilterMode%"=="all" (
    set "GameFilter=1024-65535"
    set "GameFilterTCP=1024-65535"
    set "GameFilterUDP=1024-65535"
) else if /i "%GameFilterMode%"=="tcp" (
    set "GameFilter=1024-65535"
    set "GameFilterTCP=1024-65535"
    set "GameFilterUDP=12"
) else (
    set "GameFilter=1024-65535"
    set "GameFilterTCP=12"
    set "GameFilterUDP=1024-65535"
)
exit /b
