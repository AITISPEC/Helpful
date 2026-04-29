@echo off
chcp 65001 >nul
color a
title Проверка подписи и тестовый режим

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Требуются права администратора!
    pause
    exit /b
)

:menu
cls
:: Определяем статус NOINTEGRITYCHECKS (отключена ли проверка подписи)
set "INTEGRITY=ВЫКЛЮЧЕНА"
for /f "tokens=*" %%a in ('bcdedit /enum ^| findstr /i "NOINTEGRITYCHECKS"') do (
    echo %%a | findstr /i "ON" >nul && set "INTEGRITY=ВКЛЮЧЕНА"
    echo %%a | findstr /i "Вкл" >nul && set "INTEGRITY=ВКЛЮЧЕНА"
    echo %%a | findstr /i "Yes" >nul && set "INTEGRITY=ВКЛЮЧЕНА"
    echo %%a | findstr /i "Да" >nul && set "INTEGRITY=ВКЛЮЧЕНА"
)

:: Определяем статус TESTSIGNING (тестовый режим)
set "TESTSIGN=ВЫКЛЮЧЕН"
for /f "tokens=*" %%a in ('bcdedit /enum ^| findstr /i "TESTSIGNING"') do (
    echo %%a | findstr /i "ON" >nul && set "TESTSIGN=ВКЛЮЧЕН"
    echo %%a | findstr /i "Вкл" >nul && set "TESTSIGN=ВКЛЮЧЕН"
    echo %%a | findstr /i "Yes" >nul && set "TESTSIGN=ВКЛЮЧЕН"
    echo %%a | findstr /i "Да" >nul && set "TESTSIGN=ВКЛЮЧЕН"
)

echo Проверка подписи: %INTEGRITY%
echo Тестовый режим:   %TESTSIGN%
echo.

:: Формируем пункты меню в зависимости от текущего состояния
if /i "%INTEGRITY%"=="ВКЛЮЧЕНА" (
    echo 1 - Отключить проверку подписи
) else (
    echo 1 - Включить проверку подписи
)

if /i "%TESTSIGN%"=="ВКЛЮЧЕН" (
    echo 2 - Отключить тестовый режим
) else (
    echo 2 - Включить тестовый режим
)

echo 3 - Перезагрузить компьютер
echo.
set /p choice="Выберите действие (1-3): "

if "%choice%"=="1" goto toggle_integrity
if "%choice%"=="2" goto toggle_testsigning
if "%choice%"=="3" goto reboot
goto menu

:toggle_integrity
if /i "%INTEGRITY%"=="ВКЛЮЧЕНА" (
    echo Включаем проверку подписи...
    bcdedit -set loadoptions ENABLE_INTEGRITY_CHECKS
    bcdedit -set NOINTEGRITYCHECKS OFF
) else (
    echo Отключаем проверку подписи...
    bcdedit -set loadoptions DISABLE_INTEGRITY_CHECKS
    bcdedit -set NOINTEGRITYCHECKS ON
)
echo Готово. Требуется перезагрузка.
pause
goto menu

:toggle_testsigning
if /i "%TESTSIGN%"=="ВКЛЮЧЕН" (
    echo Отключаем тестовый режим...
    bcdedit -set TESTSIGNING OFF
) else (
    echo Включаем тестовый режим...
    bcdedit -set TESTSIGNING ON
)
echo Готово. Требуется перезагрузка.
pause
goto menu

:reboot
choice /c yn /m:"Перезагрузить компьютер сейчас?"
if %errorlevel%==1 shutdown /r /t 0
goto menu
