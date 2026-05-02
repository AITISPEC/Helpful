@echo off
chcp 65001 >nul
color a
title Apex Legends: Проброс портов (TCP/UDP)

:: Проверка прав администратора
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin

:menu
cls
echo =======================================
echo    Apex Legends - Проброс портов
echo =======================================
echo.
echo   Запущено с правами администратора.
echo.
echo   [1] Создать правила (TCP + UDP отдельно)
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
echo Создание правил брандмауэра для Apex Legends...
echo.

:: ---------- TCP порты ----------
set PORTS_TCP=80 443 9988 17502 20000-20100 22990 42127 27015-27030 27036-27037

echo === TCP порты ===
for %%P in (%PORTS_TCP%) do (
    echo Обработка порта/диапазона %%P...
    for %%Q in (TCP) do (
        :: Входящее правило
        netsh advfirewall firewall show rule name="Apex %%P %%Q (входящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Входящее правило %%Q для %%P уже существует
        ) else (
            echo   Создаю входящее правило %%Q для %%P...
            netsh advfirewall firewall add rule name="Apex %%P %%Q (входящий)" dir=in action=allow protocol=%%Q localport=%%P
        )
        :: Исходящее правило
        netsh advfirewall firewall show rule name="Apex %%P %%Q (исходящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Исходящее правило %%Q для %%P уже существует
        ) else (
            echo   Создаю исходящее правило %%Q для %%P...
            netsh advfirewall firewall add rule name="Apex %%P %%Q (исходящий)" dir=out action=allow protocol=%%Q localport=%%P
        )
    )
    echo.
)

:: ---------- UDP порты ----------
set PORTS_UDP=3659 37000-38999 14000-14016 22990-23006 25200-25300 27015-27030 27031-27036

echo === UDP порты ===
for %%P in (%PORTS_UDP%) do (
    echo Обработка порта/диапазона %%P...
    for %%Q in (UDP) do (
        :: Входящее правило
        netsh advfirewall firewall show rule name="Apex %%P %%Q (входящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Входящее правило %%Q для %%P уже существует
        ) else (
            echo   Создаю входящее правило %%Q для %%P...
            netsh advfirewall firewall add rule name="Apex %%P %%Q (входящий)" dir=in action=allow protocol=%%Q localport=%%P
        )
        :: Исходящее правило
        netsh advfirewall firewall show rule name="Apex %%P %%Q (исходящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Исходящее правило %%Q для %%P уже существует
        ) else (
            echo   Создаю исходящее правило %%Q для %%P...
            netsh advfirewall firewall add rule name="Apex %%P %%Q (исходящий)" dir=out action=allow protocol=%%Q localport=%%P
        )
    )
    echo.
)

echo Готово! Правила созданы для TCP и UDP отдельно.
pause
goto menu

:check
cls
echo =======================================
echo    ПРОВЕРКА ПРАВИЛ БРАНДМАУЭРА (Apex)
echo =======================================
echo.
echo Правила для Apex Legends:
echo.

echo === TCP порты ===
set PORTS_TCP=80 443 9988 17502 20000-20100 22990 42127 27015-27030 27036-27037
for %%P in (%PORTS_TCP%) do (
    echo   TCP порт/диапазон %%P:
    for %%Q in (TCP) do (
        netsh advfirewall firewall show rule name="Apex %%P %%Q (входящий)" >nul 2>&1
        if errorlevel 1 ( echo     Входящий %%Q ... НЕТ ) else ( echo     Входящий %%Q ... ДА )
        netsh advfirewall firewall show rule name="Apex %%P %%Q (исходящий)" >nul 2>&1
        if errorlevel 1 ( echo     Исходящий %%Q ... НЕТ ) else ( echo     Исходящий %%Q ... ДА )
    )
    echo.
)

echo === UDP порты ===
set PORTS_UDP=3659 37000-38999 14000-14016 22990-23006 25200-25300 27015-27030 27031-27036
for %%P in (%PORTS_UDP%) do (
    echo   UDP порт/диапазон %%P:
    for %%Q in (UDP) do (
        netsh advfirewall firewall show rule name="Apex %%P %%Q (входящий)" >nul 2>&1
        if errorlevel 1 ( echo     Входящий %%Q ... НЕТ ) else ( echo     Входящий %%Q ... ДА )
        netsh advfirewall firewall show rule name="Apex %%P %%Q (исходящий)" >nul 2>&1
        if errorlevel 1 ( echo     Исходящий %%Q ... НЕТ ) else ( echo     Исходящий %%Q ... ДА )
    )
    echo.
)

echo =======================================
echo    ДА — правило существует и активно
echo    НЕТ — правило не найдено
echo =======================================
echo.
pause
goto menu

:delete
cls
echo Удаление правил брандмауэра для Apex Legends...
echo.

set PORTS_TCP=80 443 9988 17502 20000-20100 22990 42127 27015-27030 27036-27037
set PORTS_UDP=3659 37000-38999 14000-14016 22990-23006 25200-25300 27015-27030 27031-27036

echo Удаление TCP правил...
for %%P in (%PORTS_TCP%) do (
    for %%Q in (TCP) do (
        netsh advfirewall firewall show rule name="Apex %%P %%Q (входящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Удаляю входящее %%Q для %%P...
            netsh advfirewall firewall delete rule name="Apex %%P %%Q (входящий)"
        ) else (
            echo   Входящее %%Q для %%P не найдено
        )
        netsh advfirewall firewall show rule name="Apex %%P %%Q (исходящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Удаляю исходящее %%Q для %%P...
            netsh advfirewall firewall delete rule name="Apex %%P %%Q (исходящий)"
        ) else (
            echo   Исходящее %%Q для %%P не найдено
        )
    )
)

echo Удаление UDP правил...
for %%P in (%PORTS_UDP%) do (
    for %%Q in (UDP) do (
        netsh advfirewall firewall show rule name="Apex %%P %%Q (входящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Удаляю входящее %%Q для %%P...
            netsh advfirewall firewall delete rule name="Apex %%P %%Q (входящий)"
        ) else (
            echo   Входящее %%Q для %%P не найдено
        )
        netsh advfirewall firewall show rule name="Apex %%P %%Q (исходящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Удаляю исходящее %%Q для %%P...
            netsh advfirewall firewall delete rule name="Apex %%P %%Q (исходящий)"
        ) else (
            echo   Исходящее %%Q для %%P не найдено
        )
    )
)

echo Готово!
pause
goto menu

:NotAdmin
cls
echo =============================================
echo    ОШИБКА: Требуются права администратора!
echo =============================================
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
