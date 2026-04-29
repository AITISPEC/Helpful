@echo off
chcp 65001 >nul
color a
title Install Devcon
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin
goto go
:NotAdmin
echo.
echo Требуются права администратора!
pause
exit

:go
pause
%~d0
CD /D "%~dp0"
if not exist devcon.exe if not exist devcon64.exe (
    echo Файлы devcon.exe / devcon64.exe не найдены в текущей папке.
    pause
    exit
)
set IS_X64=0
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set IS_X64=1
if "%PROCESSOR_ARCHITEW6432%"=="AMD64" set IS_X64=1
if "%IS_X64%"=="1" goto X64

xcopy devcon.exe %systemroot%\System32 /Y
goto END

:X64
xcopy devcon.exe %systemroot%\System32 /Y
xcopy devcon64.exe %systemroot%\SysWOW64 /Y
goto END

:END
echo.
echo Installation completed successfully
pause
exit
