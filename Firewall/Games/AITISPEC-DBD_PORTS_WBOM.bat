@echo off
chcp 65001 >nul
color a
title Dead by Daylight: Проброс портов (TCP/UDP)

:: Проверка прав администратора
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 goto NotAdmin

:menu
cls
echo =======================================
echo    Dead by Daylight - Проброс портов
echo =======================================
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
echo Создание правил брандмауэра для Dead by Daylight...
echo.

:: Порты и диапазоны (одиночные и через дефис)
set PORTS=4379 4380 3478 27015-27030 27036-27037 27000-27037

for %%P in (%PORTS%) do (
    echo Обработка порта/диапазона %%P...

    for %%Q in (TCP UDP) do (
        :: Входящее правило
        netsh advfirewall firewall show rule name="DbD %%P %%Q (входящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Входящее правило %%Q для %%P уже существует
        ) else (
            echo   Создаю входящее правило %%Q для %%P...
            netsh advfirewall firewall add rule name="DbD %%P %%Q (входящий)" dir=in action=allow protocol=%%Q localport=%%P
        )

        :: Исходящее правило
        netsh advfirewall firewall show rule name="DbD %%P %%Q (исходящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Исходящее правило %%Q для %%P уже существует
        ) else (
            echo   Создаю исходящее правило %%Q для %%P...
            netsh advfirewall firewall add rule name="DbD %%P %%Q (исходящий)" dir=out action=allow protocol=%%Q localport=%%P
        )
    )
    echo.
)

echo Готово! Правила созданы для TCP и UDP.
pause
goto menu

:check
cls
echo =======================================
echo    ПРОВЕРКА ПРАВИЛ БРАНДМАУЭРА (DbD)
echo =======================================
echo.
echo Правила для Dead by Daylight:
echo.

set PORTS=4379 4380 3478 27015-27030 27036-27037 27000-27037

for %%P in (%PORTS%) do (
    echo   Порт/диапазон %%P:
    for %%Q in (TCP UDP) do (
        netsh advfirewall firewall show rule name="DbD %%P %%Q (входящий)" >nul 2>&1
        if errorlevel 1 ( echo     Входящий %%Q ... НЕТ ) else ( echo     Входящий %%Q ... ДА )

        netsh advfirewall firewall show rule name="DbD %%P %%Q (исходящий)" >nul 2>&1
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
echo Удаление правил брандмауэра для Dead by Daylight...
echo.

set PORTS=4379 4380 3478 27015-27030 27036-27037 27000-27037

for %%P in (%PORTS%) do (
    echo Обработка порта/диапазона %%P...
    for %%Q in (TCP UDP) do (
        netsh advfirewall firewall show rule name="DbD %%P %%Q (входящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Удаляю входящее правило %%Q для %%P...
            netsh advfirewall firewall delete rule name="DbD %%P %%Q (входящий)"
        ) else (
            echo   Входящее правило %%Q для %%P не найдено
        )

        netsh advfirewall firewall show rule name="DbD %%P %%Q (исходящий)" >nul 2>&1
        if not errorlevel 1 (
            echo   Удаляю исходящее правило %%Q для %%P...
            netsh advfirewall firewall delete rule name="DbD %%P %%Q (исходящий)"
        ) else (
            echo   Исходящее правило %%Q для %%P не найдено
        )
    )
    echo.
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
