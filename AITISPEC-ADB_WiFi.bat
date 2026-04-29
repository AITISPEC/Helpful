@echo off
chcp 65001 >nul
color a
title ADB Wi-fi
:menu
cls
echo.
adb tcpip 5555
echo.
echo Change TCP:
echo.
echo 1 - 0.46
echo 2 - 0.70
echo 3 - Devices
echo 4 - Other ip
echo 5 - Close adb
echo 6 - CMD
echo.
set /p choice="Your change: "
if not defined choice goto menu
if "%choice%"=="1" goto adb_1
if "%choice%"=="2" goto adb_2
if "%choice%"=="3" goto adb_dev
if "%choice%"=="4" goto adb_oth
if "%choice%"=="5" goto kill
if "%choice%"=="6" goto run_cmd
echo.
echo Error change
echo.&echo.
goto menu

:adb_1
echo.
adb connect 192.168.0.46:5555
pause
exit

:adb_2
echo.
adb connect 192.168.0.70:5555
pause
exit

:adb_dev
adb devices
pause
goto menu

:adb_oth
echo.
set /p ip="Inter ip adress (last two numbers with dot) > "
cls
adb connect 192.168.%ip%:5555
pause
exit

:kill
taskkill /f /im adb.exe
exit

:run_cmd
start cmd /k "cd /d C:\Users\Legacy\AppData\Local\Android\Sdk\platform-tools"
pause
