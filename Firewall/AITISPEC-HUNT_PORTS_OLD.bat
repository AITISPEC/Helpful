@echo off
chcp 65001 >nul
color a
title Hunt Showdown: Проброс портов (устаревш.)

:: Проверка прав администратора
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin

:menu
cls
echo ==============================================
echo   Hunt Showdown - Проброс портов (устаревш.)
echo ==============================================
echo.
echo   Запущено с правами администратора.
echo.
echo   [1] Создать правила (входящие + исходящие)
echo   [2] Проверить существующие правила
echo   [3] Удалить правила
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
echo Создание правил брандмауэра для Hunt Showdown (старые порты)...
echo.

set PORTS=3074 3478 4379-4380 27000-27050

for %%P in (%PORTS%) do (
    echo Обработка порта %%P...
    
    netsh advfirewall firewall show rule name="Hunt %%P (входящий)" >nul 2>&1
    if not errorlevel 1 (
        echo   Входящее правило для порта %%P уже существует
    ) else (
        echo   Создаю входящее правило для порта %%P...
        netsh advfirewall firewall add rule name="Hunt %%P (входящий)" dir=in action=allow protocol=TCP localport=%%P
    )
    
    netsh advfirewall firewall show rule name="Hunt %%P (исходящий)" >nul 2>&1
    if not errorlevel 1 (
        echo   Исходящее правило для порта %%P уже существует
    ) else (
        echo   Создаю исходящее правило для порта %%P...
        netsh advfirewall firewall add rule name="Hunt %%P (исходящий)" dir=out action=allow protocol=TCP localport=%%P
    )
    echo.
)

echo Готово!
pause
goto menu

:check
cls
echo ==============================================
echo        ПРОВЕРКА ПРАВИЛ БРАНДМАУЭРА
echo ==============================================
echo.
echo Правила для Hunt Showdown (старые порты):
echo.

set PORTS=3074 3478 4379-4380 27000-27050

for %%P in (%PORTS%) do (
    echo   Порт %%P:
    
    netsh advfirewall firewall show rule name="Hunt %%P (входящий)" >nul 2>&1
    if errorlevel 1 (
        echo     Входящий .... НЕТ
    ) else (
        echo     Входящий .... ДА
    )
    
    netsh advfirewall firewall show rule name="Hunt %%P (исходящий)" >nul 2>&1
    if errorlevel 1 (
        echo     Исходящий ... НЕТ
    ) else (
        echo     Исходящий ... ДА
    )
    echo.
)

echo ==============================================
echo   ДА — правило существует и активно
echo   НЕТ — правило не найдено
echo ==============================================
echo.
pause
goto menu

:delete
cls
echo Удаление правил брандмауэра для Hunt Showdown (старые порты)...
echo.

set PORTS=3074 3478 4379-4380 27000-27050

for %%P in (%PORTS%) do (
    echo Обработка порта %%P...
    
    netsh advfirewall firewall show rule name="Hunt %%P (входящий)" >nul 2>&1
    if not errorlevel 1 (
        echo   Удаляю входящее правило для порта %%P...
        netsh advfirewall firewall delete rule name="Hunt %%P (входящий)"
    ) else (
        echo   Входящее правило для порта %%P не найдено
    )
    
    netsh advfirewall firewall show rule name="Hunt %%P (исходящий)" >nul 2>&1
    if not errorlevel 1 (
        echo   Удаляю исходящее правило для порта %%P...
        netsh advfirewall firewall delete rule name="Hunt %%P (исходящий)"
    ) else (
        echo   Исходящее правило для порта %%P не найдено
    )
    echo.
)

echo Готово!
pause
goto menu

:NotAdmin
cls
echo ==============================================
echo    ОШИБКА: Требуются права администратора!
echo ==============================================
echo.
echo Пожалуйста, запустите файл от имени администратора:
echo.
echo   1. Нажмите правой кнопкой мыши на файл
echo   2. Выберите "Запуск от имени администратора"
echo.
pause
exit

:exit
exit
