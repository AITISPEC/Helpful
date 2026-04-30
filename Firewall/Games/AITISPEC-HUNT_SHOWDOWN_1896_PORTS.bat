@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
color a
title Hunt Showdown 1896: Проброс портов (все порты +UDP)

:: Проверка прав администратора
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin

:menu
cls
echo =========================================
echo    Hunt Showdown 1896 - Проброс портов
echo =========================================
echo.
echo   Запущено с правами администратора.
echo   (TCP + UDP для всех известных портов)
echo.
echo   [1] Создать правила (TCP если нет, +UDP)
echo   [2] Проверить существующие правила
echo   [3] Удалить правила (TCP + UDP)
echo   [0] Выход
echo.
set /p choice="Выберите пункт меню: "

if "%choice%"=="1" goto create
if "%choice%"=="2" goto check
if "%choice%"=="3" goto delete
if "%choice%"=="0" goto exit
echo Неверный выбор. Попробуйте снова.
pause
goto menu

:create
cls
echo Создание правил брандмауэра для Hunt Showdown 1896...
echo.

:: Объединённый список портов (актуальные + устаревшие)
set PORTS=61088 20000-20099 3074 3478 4379-4380 27000-27050

for %%P in (%PORTS%) do (
    echo Обработка порта/диапазона %%P ...

    :: TCP правила (старые имена, без изменений)
    netsh advfirewall firewall show rule name="Hunt %%P (входящий)" >nul 2>&1
    if errorlevel 1 (
        echo   Создаю TCP входящее правило для %%P...
        netsh advfirewall firewall add rule name="Hunt %%P (входящий)" dir=in action=allow protocol=TCP localport=%%P >nul
    ) else echo   TCP входящее правило для %%P уже существует

    netsh advfirewall firewall show rule name="Hunt %%P (исходящий)" >nul 2>&1
    if errorlevel 1 (
        echo   Создаю TCP исходящее правило для %%P...
        netsh advfirewall firewall add rule name="Hunt %%P (исходящий)" dir=out action=allow protocol=TCP localport=%%P >nul
    ) else echo   TCP исходящее правило для %%P уже существует

    :: UDP правила (новые имена с суффиксом UDP)
    netsh advfirewall firewall show rule name="Hunt %%P UDP (входящий)" >nul 2>&1
    if errorlevel 1 (
        echo   Создаю UDP входящее правило для %%P...
        netsh advfirewall firewall add rule name="Hunt %%P UDP (входящий)" dir=in action=allow protocol=UDP localport=%%P >nul
    ) else echo   UDP входящее правило для %%P уже существует

    netsh advfirewall firewall show rule name="Hunt %%P UDP (исходящий)" >nul 2>&1
    if errorlevel 1 (
        echo   Создаю UDP исходящее правило для %%P...
        netsh advfirewall firewall add rule name="Hunt %%P UDP (исходящий)" dir=out action=allow protocol=UDP localport=%%P >nul
    ) else echo   UDP исходящее правило для %%P уже существует

    echo.
)

echo Готово! TCP и UDP правила обработаны.
pause
goto menu

:check
cls
echo ==============================================
echo        ПРОВЕРКА ПРАВИЛ БРАНДМАУЭРА
echo ==============================================
echo.
echo Правила для Hunt Showdown 1896 (все порты):
echo.

set PORTS=61088 20000-20099 3074 3478 4379-4380 27000-27050

for %%P in (%PORTS%) do (
    echo   Порт/диапазон %%P:

    set "tcp_in=НЕТ"
    set "tcp_out=НЕТ"
    netsh advfirewall firewall show rule name="Hunt %%P (входящий)" >nul 2>&1 && set "tcp_in=ДА"
    netsh advfirewall firewall show rule name="Hunt %%P (исходящий)" >nul 2>&1 && set "tcp_out=ДА"
    echo     TCP входящий: !tcp_in!, исходящий: !tcp_out!

    set "udp_in=НЕТ"
    set "udp_out=НЕТ"
    netsh advfirewall firewall show rule name="Hunt %%P UDP (входящий)" >nul 2>&1 && set "udp_in=ДА"
    netsh advfirewall firewall show rule name="Hunt %%P UDP (исходящий)" >nul 2>&1 && set "udp_out=ДА"
    echo     UDP входящий: !udp_in!, исходящий: !udp_out!
    echo.
)

echo ==============================================
pause
goto menu

:delete
cls
echo Удаление правил брандмауэра для Hunt Showdown 1896 (все порты)...
echo.

set PORTS=61088 20000-20099 3074 3478 4379-4380 27000-27050

for %%P in (%PORTS%) do (
    echo Обработка порта/диапазона %%P...
    netsh advfirewall firewall delete rule name="Hunt %%P (входящий)" >nul 2>&1
    netsh advfirewall firewall delete rule name="Hunt %%P (исходящий)" >nul 2>&1
    netsh advfirewall firewall delete rule name="Hunt %%P UDP (входящий)" >nul 2>&1
    netsh advfirewall firewall delete rule name="Hunt %%P UDP (исходящий)" >nul 2>&1
    echo   Удалены правила для %%P
    echo.
)

echo Готово! Все правила удалены.
pause
goto menu

:NotAdmin
cls
echo ==============================================
echo    ОШИБКА: Требуются права администратора!
echo ==============================================
echo.
echo Пожалуйста, запустите файл от имени администратора:
echo   1. Нажмите правой кнопкой мыши на файл
echo   2. Выберите "Запуск от имени администратора"
echo.
pause
exit

:exit
exit
