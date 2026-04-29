@echo off
chcp 65001 >nul
color a
title Icon Cache Cleaner
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin
goto menu
:NotAdmin
echo.
echo Требуются права администратора!
pause
exit

:menu
cls
echo.
echo Будет выполнена перезагрузка! Продолжить?
echo.
choice /c yn /m:"Accept"
if %errorlevel%==2 exit
echo Очистка кэша иконок...
ie4uinit.exe -show
taskkill /IM explorer.exe /F
DEL /A /Q "%localappdata%\IconCache.db" 2>nul
DEL /A /F /Q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" 2>nul
shutdown /r /f /t 00
