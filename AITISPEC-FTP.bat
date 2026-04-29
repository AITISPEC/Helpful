@echo off
chcp 65001 >nul
color a
title FTP
:menu
cls
echo Change FTP:
echo.
set /a port=6559
echo Port:%port%
echo.
echo 1 - 192.168.0.92
echo 2 - 192.168.0.6
echo 3 - 192.168.0.25
echo 4 - Other ip
echo.
set /p choice="Your change: "
if not defined choice goto menu
if "%choice%"=="1" goto wifi_1
if "%choice%"=="2" goto wifi_2
if "%choice%"=="3" goto wifi_3
if "%choice%"=="4" goto wifi_other
echo.
echo Error change
pause
goto menu

:wifi_1
set "ftp_host=192.168.0.92"
goto check_ftp
:wifi_2
set "ftp_host=192.168.0.6"
goto check_ftp
:wifi_3
set "ftp_host=192.168.0.25"
goto check_ftp
:wifi_other
set /p ip="Enter last two numbers with dot (e.g., 0.123): "
set "ftp_host=192.168.%ip%"
goto check_ftp

:check_ftp
echo Проверка доступности %ftp_host% ...
ping -n 1 -w 1000 %ftp_host% >nul 2>&1
if %errorlevel% equ 0 (
    echo Хост доступин. Открытие FTP...
    start explorer ftp://%ftp_host%:%port%
    exit
) else (
    echo Хост недоступен %ftp_host%. Проверьте адрес или интернет.
    pause
    goto menu
)
