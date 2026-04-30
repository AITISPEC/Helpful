@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Update Zapret + WARP

:: ===== Автозапуск от имени администратора =====
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit
)

:: ===== Проверка папки update =====
if not exist "%~dp0update\" (
    echo [INFO] Папка update не найдена. Поместите новую версию в папку update.
    pause
    exit /b
)

set "UPDATE_HAS_FILES=0"
for /f "delims=" %%F in ('dir /a /b "%~dp0update\*" 2^>nul') do set "UPDATE_HAS_FILES=1"

if "!UPDATE_HAS_FILES!"=="0" (
    echo [INFO] Папка update пуста. Поместите новую версию в папку update.
    pause
    exit /b
)

:: ===== Проверка структуры папки update =====
if not exist "%~dp0update\bin\" (
    echo [INFO] В папке update нет папки bin. Поместите новую версию полностью.
    pause
    exit /b
)

if not exist "%~dp0update\lists\" (
    echo [INFO] В папке update нет папки lists. Поместите новую версию полностью.
    pause
    exit /b
)

:: Выполняем команду установки протокола MASQUE
warp-cli tunnel protocol set MASQUE >nul 2>&1
if errorlevel 0 (
    echo [OK] Туннель WARP установлен на MASQUE.
) else (
    echo [WARN] Не удалось установить протокол MASQUE для WARP.
)

:run_update
:: ===== Проверяем сервис перед обновлением =====
set "SERVICE_WAS_RUNNING=0"
set "SERVICE_STRATEGY="

echo [INFO] Проверка состояния сервиса...
call "%~dp0update_core.bat" status_strategy
if errorlevel 1 (
    echo [INFO] Сервис запущен, получаю стратегию...
    set "SERVICE_WAS_RUNNING=1"
    for /f "delims=" %%s in ('call "%~dp0update_core.bat" get_strategy') do set "SERVICE_STRATEGY=%%s"
    echo [INFO] Текущая стратегия: !SERVICE_STRATEGY!
    echo [INFO] Останавливаю сервис...
    call "%~dp0update_core.bat" remove
) else (
    echo [INFO] Сервис не запущен, продолжаю обновление
)

:: Запускаем основной скрипт обновления в любом случае
powershell -ExecutionPolicy Bypass -File "%~dp0update_script.ps1"

:: ===== Перезапускаем сервис после обновления =====
if "!SERVICE_WAS_RUNNING!"=="1" (
    echo [INFO] Перезапуск сервиса со стратегией: !SERVICE_STRATEGY!
    call "%~dp0update_core.bat" install "!SERVICE_STRATEGY!"
)

echo [OK] Обновление завершено.
pause
