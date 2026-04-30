@echo off
chcp 65001 >nul
color a
title Включение Защитника Windows (WinDefend + wscsvc)

:: Переход в папку скрипта
cd /d "%~dp0"

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Требуются права администратора!
    pause
    exit /b
)

echo =======================================================
echo Включение служб Защитника Windows и центра безопасности
echo =======================================================
echo.

:: Проверяем наличие reg-файлов
if not exist "WinDefend.reg" (
    echo [ОШИБКА] Файл WinDefend.reg не найден в папке:
    echo %~dp0
    pause
    exit /b
)
if not exist "wscsvc.reg" (
    echo [ОШИБКА] Файл wscsvc.reg не найден в папке:
    echo %~dp0
    pause
    exit /b
)

echo 1. Импорт WinDefend.reg (служба Защитника)...
regedit.exe /s "WinDefend.reg"
if %errorlevel% equ 0 (echo [OK]) else (echo [ОШИБКА])
echo.

echo 2. Импорт wscsvc.reg (центр безопасности)...
regedit.exe /s "wscsvc.reg"
if %errorlevel% equ 0 (echo [OK]) else (echo [ОШИБКА])
echo.

echo 3. Перезагрузка компьютера...
choice /c yn /m:"Перезагрузить сейчас?"
if %errorlevel% equ 2 exit
if %errorlevel% equ 1 shutdown /r /t 0
