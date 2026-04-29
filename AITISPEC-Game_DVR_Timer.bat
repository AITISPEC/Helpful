@echo off
title Game DVR Timer
chcp 65001 >nul
color a

echo =============================================
echo  Выберите тайминг для Game DVR:
echo =============================================
echo [1] 4 часа
echo [2] 2 часа
echo [3] 1 час
echo [4] 30 минут
echo [5] 15 минут
echo [6] 10 минут
echo [7] 5 минут
echo [0] Выход
echo =============================================

set /p choice="Введите номер (1-8): "

if "%choice%"=="0" exit /b
if "%choice%"=="1" set "value=144000000000" & set "name=4 часа"
if "%choice%"=="2" set "value=72000000000" & set "name=2 часа"
if "%choice%"=="3" set "value=36000000000" & set "name=1 час"
if "%choice%"=="4" set "value=18000000000" & set "name=30 минут"
if "%choice%"=="5" set "value=9000000000" & set "name=15 минут"
if "%choice%"=="6" set "value=6000000000" & set "name=10 минут"
if "%choice%"=="7" set "value=3000000000" & set "name=5 минут"

if "%value%"=="" (
    color c
    echo Неверный ввод. Нажмите любую клавишу...
    pause >nul
    exit /b
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v MaximumRecordLength /t REG_QWORD /d %value% /f >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo =============================================
    echo  [OK] Установлено: %name%
    echo  Путь: HKCU\Software\...\GameDVR
    echo  Перезапустите Game Bar ^(Win+G^)
    echo =============================================
) else (
    color c
    echo.
    echo =============================================
    echo  [ERROR] Не удалось записать в реестр.
    echo  Запустите файл от имени Администратора.
    echo =============================================
)

pause
exit /b
