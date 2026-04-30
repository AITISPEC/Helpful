@echo off
chcp 65001 >nul
color a
title Update Zapret + WARP

:: Проверяем, доступен ли warp-cli
where warp-cli >nul 2>&1
if errorlevel 1 (
    echo [WARN] warp-cli не найден. Установите Cloudflare WARP.
    echo [INFO] Обновление продолжится без настройки туннеля.
    goto :run_update
)

:: Выполняем команду установки протокола MASQUE
warp-cli tunnel protocol set MASQUE >nul 2>&1
if errorlevel 0 (
    echo [OK] Туннель WARP установлен на MASQUE.
) else (
    echo [WARN] Не удалось установить протокол MASQUE для WARP.
)

:run_update
:: Запускаем основной скрипт обновления в любом случае
powershell -ExecutionPolicy Bypass -File "%~dp0update.ps1"