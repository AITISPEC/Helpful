@echo off
chcp 65001 >nul
color a
title Epic Games Store: проброс портов

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 goto NotAdmin

:menu
cls
echo ==========================================
echo   Epic Games Store - Проброс портов
echo ==========================================
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
echo Создание правил брандмауэра для Epic Games Store...
echo.
echo Добавление TCP правил...
netsh advfirewall firewall add rule name="EGS 80 TCP (in)" dir=in action=allow protocol=TCP localport=80 >nul
netsh advfirewall firewall add rule name="EGS 80 TCP (out)" dir=out action=allow protocol=TCP localport=80 >nul
netsh advfirewall firewall add rule name="EGS 443 TCP (in)" dir=in action=allow protocol=TCP localport=443 >nul
netsh advfirewall firewall add rule name="EGS 443 TCP (out)" dir=out action=allow protocol=TCP localport=443 >nul
netsh advfirewall firewall add rule name="EGS 3478 TCP (in)" dir=in action=allow protocol=TCP localport=3478 >nul
netsh advfirewall firewall add rule name="EGS 3478 TCP (out)" dir=out action=allow protocol=TCP localport=3478 >nul
netsh advfirewall firewall add rule name="EGS 3479 TCP (in)" dir=in action=allow protocol=TCP localport=3479 >nul
netsh advfirewall firewall add rule name="EGS 3479 TCP (out)" dir=out action=allow protocol=TCP localport=3479 >nul
netsh advfirewall firewall add rule name="EGS 5060 TCP (in)" dir=in action=allow protocol=TCP localport=5060 >nul
netsh advfirewall firewall add rule name="EGS 5060 TCP (out)" dir=out action=allow protocol=TCP localport=5060 >nul
netsh advfirewall firewall add rule name="EGS 5062 TCP (in)" dir=in action=allow protocol=TCP localport=5062 >nul
netsh advfirewall firewall add rule name="EGS 5062 TCP (out)" dir=out action=allow protocol=TCP localport=5062 >nul
netsh advfirewall firewall add rule name="EGS 5222 TCP (in)" dir=in action=allow protocol=TCP localport=5222 >nul
netsh advfirewall firewall add rule name="EGS 5222 TCP (out)" dir=out action=allow protocol=TCP localport=5222 >nul
netsh advfirewall firewall add rule name="EGS 6250 TCP (in)" dir=in action=allow protocol=TCP localport=6250 >nul
netsh advfirewall firewall add rule name="EGS 6250 TCP (out)" dir=out action=allow protocol=TCP localport=6250 >nul
echo TCP правила добавлены.

echo Добавление UDP правил...
netsh advfirewall firewall add rule name="EGS 3478 UDP (in)" dir=in action=allow protocol=UDP localport=3478 >nul
netsh advfirewall firewall add rule name="EGS 3478 UDP (out)" dir=out action=allow protocol=UDP localport=3478 >nul
netsh advfirewall firewall add rule name="EGS 3479 UDP (in)" dir=in action=allow protocol=UDP localport=3479 >nul
netsh advfirewall firewall add rule name="EGS 3479 UDP (out)" dir=out action=allow protocol=UDP localport=3479 >nul
netsh advfirewall firewall add rule name="EGS 5060 UDP (in)" dir=in action=allow protocol=UDP localport=5060 >nul
netsh advfirewall firewall add rule name="EGS 5060 UDP (out)" dir=out action=allow protocol=UDP localport=5060 >nul
netsh advfirewall firewall add rule name="EGS 5062 UDP (in)" dir=in action=allow protocol=UDP localport=5062 >nul
netsh advfirewall firewall add rule name="EGS 5062 UDP (out)" dir=out action=allow protocol=UDP localport=5062 >nul
netsh advfirewall firewall add rule name="EGS 5222 UDP (in)" dir=in action=allow protocol=UDP localport=5222 >nul
netsh advfirewall firewall add rule name="EGS 5222 UDP (out)" dir=out action=allow protocol=UDP localport=5222 >nul
netsh advfirewall firewall add rule name="EGS 6250 UDP (in)" dir=in action=allow protocol=UDP localport=6250 >nul
netsh advfirewall firewall add rule name="EGS 6250 UDP (out)" dir=out action=allow protocol=UDP localport=6250 >nul
echo UDP правила добавлены.

echo.
echo Готово! Все правила созданы.
pause
goto menu

:check
cls
echo ==============================================
echo   ПРОВЕРКА ПРАВИЛ БРАНДМАУЭРА (EGS)
echo ==============================================
echo.
echo --- TCP правила ---

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 80 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 80 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 80 TCP   : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 443 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 443 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 443 TCP  : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 3478 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 3478 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 3478 TCP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 3479 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 3479 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 3479 TCP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 5060 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 5060 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 5060 TCP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 5062 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 5062 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 5062 TCP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 5222 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 5222 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 5222 TCP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 6250 TCP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 6250 TCP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 6250 TCP : входящий %in%, исходящий %out%

echo.
echo --- UDP правила ---

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 3478 UDP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 3478 UDP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 3478 UDP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 3479 UDP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 3479 UDP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 3479 UDP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 5060 UDP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 5060 UDP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 5060 UDP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 5062 UDP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 5062 UDP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 5062 UDP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 5222 UDP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 5222 UDP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 5222 UDP : входящий %in%, исходящий %out%

set "in="
set "out="
netsh advfirewall firewall show rule name="EGS 6250 UDP (in)" >nul 2>&1 && set "in=ДА" || set "in=НЕТ"
netsh advfirewall firewall show rule name="EGS 6250 UDP (out)" >nul 2>&1 && set "out=ДА" || set "out=НЕТ"
echo Порт 6250 UDP : входящий %in%, исходящий %out%

echo.
echo ==============================================
pause
goto menu

:delete
cls
echo Удаление правил брандмауэра для Epic Games Store...
echo Удаляю TCP правила...
netsh advfirewall firewall delete rule name="EGS 80 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 80 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 443 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 443 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3478 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3478 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3479 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3479 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5060 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5060 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5062 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5062 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5222 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5222 TCP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 6250 TCP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 6250 TCP (out)" >nul 2>&1

echo Удаляю UDP правила...
netsh advfirewall firewall delete rule name="EGS 3478 UDP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3478 UDP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3479 UDP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 3479 UDP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5060 UDP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5060 UDP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5062 UDP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5062 UDP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5222 UDP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 5222 UDP (out)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 6250 UDP (in)" >nul 2>&1
netsh advfirewall firewall delete rule name="EGS 6250 UDP (out)" >nul 2>&1

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
