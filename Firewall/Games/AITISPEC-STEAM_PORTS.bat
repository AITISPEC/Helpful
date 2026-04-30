@echo off
chcp 65001 >nul
color a
title Steam: проброс портов

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 goto NotAdmin

:menu
cls
echo ==============================================
echo      Steam - Проброс портов
echo ==============================================
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
echo Неверный выбор.
pause
goto menu

:create
cls
echo Создание правил брандмауэра для Steam...
echo.

echo Добавление TCP правил...
netsh advfirewall firewall add rule name="Steam TCP 80 (in)" dir=in action=allow protocol=TCP localport=80 >nul
netsh advfirewall firewall add rule name="Steam TCP 80 (out)" dir=out action=allow protocol=TCP localport=80 >nul

netsh advfirewall firewall add rule name="Steam TCP 443 (in)" dir=in action=allow protocol=TCP localport=443 >nul
netsh advfirewall firewall add rule name="Steam TCP 443 (out)" dir=out action=allow protocol=TCP localport=443 >nul

netsh advfirewall firewall add rule name="Steam TCP 27015-27030 (in)" dir=in action=allow protocol=TCP localport=27015-27030 >nul
netsh advfirewall firewall add rule name="Steam TCP 27015-27030 (out)" dir=out action=allow protocol=TCP localport=27015-27030 >nul

netsh advfirewall firewall add rule name="Steam TCP 27036-27037 (in)" dir=in action=allow protocol=TCP localport=27036-27037 >nul
netsh advfirewall firewall add rule name="Steam TCP 27036-27037 (out)" dir=out action=allow protocol=TCP localport=27036-27037 >nul
echo TCP правила добавлены.

echo Добавление UDP правил...
netsh advfirewall firewall add rule name="Steam UDP 27000-27030 (in)" dir=in action=allow protocol=UDP localport=27000-27030 >nul
netsh advfirewall firewall add rule name="Steam UDP 27000-27030 (out)" dir=out action=allow protocol=UDP localport=27000-27030 >nul

netsh advfirewall firewall add rule name="Steam UDP 27031-27036 (in)" dir=in action=allow protocol=UDP localport=27031-27036 >nul
netsh advfirewall firewall add rule name="Steam UDP 27031-27036 (out)" dir=out action=allow protocol=UDP localport=27031-27036 >nul

netsh advfirewall firewall add rule name="Steam UDP 3478 (in)" dir=in action=allow protocol=UDP localport=3478 >nul
netsh advfirewall firewall add rule name="Steam UDP 3478 (out)" dir=out action=allow protocol=UDP localport=3478 >nul

netsh advfirewall firewall add rule name="Steam UDP 4379 (in)" dir=in action=allow protocol=UDP localport=4379 >nul
netsh advfirewall firewall add rule name="Steam UDP 4379 (out)" dir=out action=allow protocol=UDP localport=4379 >nul

netsh advfirewall firewall add rule name="Steam UDP 4380 (in)" dir=in action=allow protocol=UDP localport=4380 >nul
netsh advfirewall firewall add rule name="Steam UDP 4380 (out)" dir=out action=allow protocol=UDP localport=4380 >nul
echo UDP правила добавлены.

echo.
echo Готово! Все правила созданы.
pause
goto menu

:check
cls
echo ==============================================
echo   ПРОВЕРКА ПРАВИЛ БРАНДМАУЭРА (Steam)
echo ==============================================
echo.
echo --- TCP правила ---

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam TCP 80 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam TCP 80 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 80 TCP         : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam TCP 443 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam TCP 443 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 443 TCP        : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam TCP 27015-27030 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam TCP 27015-27030 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo TCP 27015-27030     : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam TCP 27036-27037 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam TCP 27036-27037 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo TCP 27036-27037     : входящий %in%, исходящий %out%

echo.
echo --- UDP правила ---

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam UDP 27000-27030 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam UDP 27000-27030 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo UDP 27000-27030     : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam UDP 27031-27036 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam UDP 27031-27036 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo UDP 27031-27036     : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam UDP 3478 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam UDP 3478 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 3478 UDP       : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam UDP 4379 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam UDP 4379 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 4379 UDP       : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="Steam UDP 4380 (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="Steam UDP 4380 (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 4380 UDP       : входящий %in%, исходящий %out%

echo.
echo ==============================================
pause
goto menu

:delete
cls
echo Удаление правил брандмауэра для Steam...
echo Удаляю TCP правила...
netsh advfirewall firewall delete rule name="Steam TCP 80 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 80 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 443 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 443 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 27015-27030 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 27015-27030 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 27036-27037 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam TCP 27036-27037 (out)" >nul 2>&1

echo Удаляю UDP правила...
netsh advfirewall firewall delete rule name="Steam UDP 27000-27030 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 27000-27030 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 27031-27036 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 27031-27036 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 3478 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 3478 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 4379 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 4379 (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 4380 (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="Steam UDP 4380 (out)" >nul 2>&1

echo Готово! Правила удалены.
pause
goto menu

:NotAdmin
cls
echo ==============================================
echo    ОШИБКА: Требуются права администратора!
echo ==============================================
echo.
echo Пожалуйста, запустите файл от имени администратора.
pause
exit

:exit
exit
