@echo off
chcp 65001 >nul
color a
title PreSleep Music
cls
where nircmd >nul 2>nul
if %errorlevel% neq 0 (
    echo nircmd.exe не найден. Установите NIRcmd.
    pause
    exit
)
set /p min="Через сколько минут включить музыку? > "
set /a sec=%min%*60
cls
timeout /t %sec% /nobreak
nircmd.exe sendkeypress Ctrl+TAB
timeout /t 3 /nobreak
nircmd.exe sendkeypress spc
pause
