@echo off
chcp 65001 >nul
color a
title Startup Folders
:menu
cls
echo Change folder:
echo.
echo 1 - Current user
echo 2 - All users
echo.
set /p choice="Your change: "
if not defined choice goto menu
if "%choice%"=="1" goto cur
if "%choice%"=="2" goto all
echo.
echo Error change
pause
goto menu

:cur
explorer %userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
exit
:all
explorer %ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup
exit
