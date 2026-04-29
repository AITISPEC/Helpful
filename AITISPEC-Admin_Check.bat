@echo off
chcp 65001 >nul
color a
title Admin Check
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin
:menu
cls
echo Запущено с правами администратора.
echo.
pause
exit

:NotAdmin
echo.
echo Требуются права администратора!
echo.
pause
exit
