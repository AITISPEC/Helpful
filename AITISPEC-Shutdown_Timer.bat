@echo off
chcp 65001 >nul
color a
title Shutdown Timer
shutdown -a
cls
echo Таймер сброшен.
set /p min="Через сколько минут выключить? > "
set /a sec=%min%*60
cls
echo Выключение через %min% мин.
choice /c yn /m:"Accept?"
if %errorlevel%==2 (
    shutdown -a
    cls
    echo Отменено.
) else (
    shutdown /s /t %sec%
)
pause
