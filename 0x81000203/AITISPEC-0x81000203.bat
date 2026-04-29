@echo off
chcp 65001 >nul
color a
title Восстановление ошибки 0x81000203 (теневые копии)

:: Переход в папку скрипта
cd /d "%~dp0"

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Требуются права администратора!
    pause
    exit /b
)

echo ===============================================================
echo Восстановление службы теневого копирования (ошибка 0x81000203)
echo ===============================================================
echo.

:: 1. Создание службы (только если её нет)
echo 1. Проверка службы swprv...
sc query swprv >nul 2>&1
if %errorlevel% equ 0 (
    echo Служба swprv уже существует, пропускаем создание.
) else (
    echo Создание службы swprv...
    sc create swprv binPath= C:\Windows\System32\svchost.exe DisplayName= "Программный поставщик теневого копирования (Microsoft)" type= own start= demand error= normal depend= rpcss obj= LocalSystem
    if %errorlevel% equ 0 (echo [OK]) else (echo [ОШИБКА])
)
echo.

:: 2. Добавление параметров реестра
echo 2. Добавление параметров реестра...
reg add HKLM\SYSTEM\CurrentControlSet\services\swprv /v ImagePath /d "C:\Windows\System32\svchost.exe -k swprv" /f >nul
if %errorlevel% equ 0 (echo [OK] ImagePath) else (echo [ОШИБКА] ImagePath)

reg add HKLM\SYSTEM\CurrentControlSet\services\swprv\Parameters /v ServiceDll /d "%Systemroot%\System32\swprv.dll" /f >nul
if %errorlevel% equ 0 (echo [OK] ServiceDll) else (echo [ОШИБКА] ServiceDll)

:: Импорт reg-файла (если есть)
if exist "0x81000203.reg" (
    regedit.exe /s "0x81000203.reg"
    echo [OK] Импортирован 0x81000203.reg
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] Файл 0x81000203.reg не найден (пропускаем)
)
echo.

:: 3. Перезагрузка
echo 3. Перезагрузка компьютера...
choice /c yn /m:"Перезагрузить сейчас?"
if %errorlevel% equ 2 exit
if %errorlevel% equ 1 shutdown /r /t 0
