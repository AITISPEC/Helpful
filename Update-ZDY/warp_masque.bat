@echo off
chcp 65001 >nul
title WARP MASQUE Setup

:: Автозапуск от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -NoProfile -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit
)

where warp-cli >nul 2>&1
if errorlevel 1 (
    echo [WARN] warp-cli не найден. Установите Cloudflare WARP.
    pause
    exit /b
)

warp-cli tunnel protocol set MASQUE >nul 2>&1
if errorlevel 0 (
    echo [OK] Туннель WARP установлен на MASQUE.
) else (
    echo [WARN] Не удалось установить протокол MASQUE для WARP.
)

pause
