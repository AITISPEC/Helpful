<# : adb_hybrid_menu
@echo off
chcp 65001 >nul
color a
title ADB Manager (Hybrid)

:: Отключаем опасное расширение переменных по умолчанию
setlocal disabledelayedexpansion

:: Установка рабочей папки скрипта
set "SCRIPT_DIR=%~dp0"
set "PATH_FILE=%SCRIPT_DIR%adb_path.txt"

:: Шаг 1. Проверка кэшированного пути к ADB
if exist "%PATH_FILE%" (
    set /p ADB_EXE=<"%PATH_FILE%"
)

:: Если путь пустой или кривой — ищем в стандартных местах
if "%ADB_EXE%"=="" goto find_adb
if "%ADB_EXE%"=="%%~nxB" goto find_adb
if "%ADB_EXE%"=="%%~i" goto find_adb
goto check_adb

:find_adb
echo [INFO] Поиск adb.exe на диске... Пожалуйста, подождите...
set "ADB_EXE="
if exist "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe" set "ADB_EXE=C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe"
if exist "C:\Program Files\Android\android-sdk\platform-tools\adb.exe" set "ADB_EXE=C:\Program Files\Android\android-sdk\platform-tools\adb.exe"
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" set "ADB_EXE=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"

:check_adb
:: Очищаем путь от случайных кавычек
if defined ADB_EXE (
    for /f "delims=" %%i in ("%ADB_EXE%") do set "ADB_EXE=%%~i"
)

:: Если всё еще не нашли, просим ввести вручную
if "%ADB_EXE%"=="" (
    cls
    color c
    echo [ERROR] Автоматически найти adb.exe не удалось.
    set /p ADB_EXE="Введите полный путь к adb.exe вручную: "
    if not defined ADB_EXE exit /b
)

:: Перепроверяем кавычки после ручного ввода и жестко сохраняем БЕЗ пробелов
for /f "delims=" %%i in ("%ADB_EXE%") do set "ADB_EXE=%%~i"
echo %ADB_EXE%>"%PATH_FILE%"

:menu
cls
echo =========
echo ADB Путь: %ADB_EXE%
echo =========
echo.
echo Change TCP:
echo.
echo 1 - 0.46
echo 2 - 0.70
echo 3 - Other ip
echo.
echo More options:
echo.
echo 4 - Devices
echo 5 - Close adb
echo 6 - CMD (в папке платформы)
echo 7 - Install .apk (Выбор устройства / На все)
echo.
set "choice="
set /p choice="Your change: "
if not defined choice goto menu
if "%choice%"=="1" goto adb_1
if "%choice%"=="2" goto adb_2
if "%choice%"=="3" goto adb_oth
if "%choice%"=="4" goto adb_dev
if "%choice%"=="5" goto kill
if "%choice%"=="6" goto run_cmd
if "%choice%"=="7" goto adb_install
echo.
echo Error change
echo.&echo.
goto menu

:adb_1
echo.
echo [INFO] Активация TCP-порта на подключенных устройствах...
"%ADB_EXE%" devices > "%TEMP%\sys_adb_dev.txt" 2>nul
for /f "tokens=1" %%i in ('findstr /v "List" "%TEMP%\sys_adb_dev.txt" ^| findstr "device"') do "%ADB_EXE%" -s %%i tcpip 5555
del "%TEMP%\sys_adb_dev.txt" >nul 2>&1
echo.
"%ADB_EXE%" connect 192.168.0.46:5555
pause
goto menu

:adb_2
echo.
echo [INFO] Активация TCP-порта на подключенных устройствах...
"%ADB_EXE%" devices > "%TEMP%\sys_adb_dev.txt" 2>nul
for /f "tokens=1" %%i in ('findstr /v "List" "%TEMP%\sys_adb_dev.txt" ^| findstr "device"') do "%ADB_EXE%" -s %%i tcpip 5555
del "%TEMP%\sys_adb_dev.txt" >nul 2>&1
echo.
"%ADB_EXE%" connect 192.168.0.70:5555
pause
goto menu

:adb_dev
echo.
"%ADB_EXE%" devices
pause
goto menu

:adb_oth
echo.
set /p ip="Enter ip address (last two numbers with dot) > "
cls
echo [INFO] Активация TCP-порта на подключенных устройствах...
"%ADB_EXE%" devices > "%TEMP%\sys_adb_dev.txt" 2>nul
for /f "tokens=1" %%i in ('findstr /v "List" "%TEMP%\sys_adb_dev.txt" ^| findstr "device"') do "%ADB_EXE%" -s %%i tcpip 5555
del "%TEMP%\sys_adb_dev.txt" >nul 2>&1
echo.
"%ADB_EXE%" connect 192.168.%ip%:5555
pause
goto menu

:kill
echo.
taskkill /f /im adb.exe
pause
goto menu

:run_cmd
for %%F in ("%ADB_EXE%") do set "ADB_DIR=%%~dpF"
start cmd /k "cd /d %ADB_DIR%"
goto menu

:adb_install
echo.
echo Перетащите ваш файл .apk в это окно или введите полный путь вручную:
echo.
set "user_apk="
set /p user_apk="Path to APK: "

if not defined user_apk goto menu

:: Очищаем путь к APK от кавычек
for /f "delims=" %%i in ("%user_apk%") do set "clean_apk=%%~i"

if not exist "%clean_apk%" (
    echo.
    echo [ERROR] Файл не найден по указанному пути!
    echo Путь: "%clean_apk%"
    pause
    goto menu
)

:: Получаем актуальный список устройств во временный файл
"%ADB_EXE%" devices > "%TEMP%\sys_adb_dev.txt" 2>nul

cls
echo === Доступные устройства ===
echo.

:: Сбрасываем счетчик перед циклом
set "dev_count=0"

:: Читаем файл построчно, забирая строго ТОЛЬКО первое слово (токен 1) до пробела или таба
for /f "tokens=1" %%i in ('findstr /v "List" "%TEMP%\sys_adb_dev.txt" ^| findstr /r /c:"[a-zA-O0-9]"') do (
    set /a dev_count+=1
    :: Сохраняем ТОЛЬКО ID (например, emulator-5554), слово device отсекается автоматически
    call set "dev_id_%%dev_count%%=%%i"
    call echo %%dev_count%% - %%i
)

if "%dev_count%"=="0" (
    echo [WARNING] Активные устройства не найдены!
    del "%TEMP%\sys_adb_dev.txt" >nul 2>&1
    pause
    goto menu
)

set /a all_option=dev_count+1
echo %all_option% - НА ВСЕ УСТРОЙСТВА
echo.

set "dev_choice="
set /p dev_choice="Выберите номер устройства для установки: "

if not defined dev_choice (
    del "%TEMP%\sys_adb_dev.txt" >nul 2>&1
    goto menu
)

echo.
echo [INFO] Запуск установки...
echo --------------------------------------------------

:: Проверяем, выбрал ли пользователь установку "На все"
if "%dev_choice%"=="%all_option%" (
    for /f "tokens=1" %%i in ('findstr /v "List" "%TEMP%\sys_adb_dev.txt" ^| findstr /r /c:"[a-zA-O0-9]"') do (
        echo Установка на устройство: %%i...
        "%ADB_EXE%" -s %%i install -r "%clean_apk%"
    )
    goto install_end
)

:: Извлекаем чистый ID конкретного выбранного устройства
call set "target_device=%%dev_id_%dev_choice%%%"

if "%target_device%"=="" (
    echo [ERROR] Неверный выбор номера устройства!
    del "%TEMP%\sys_adb_dev.txt" >nul 2>&1
    pause
    goto menu
)

echo Установка на устройство: %target_device%...
"%ADB_EXE%" -s %target_device% install -r "%clean_apk%"

:install_end
:: Чистим временные файлы
del "%TEMP%\sys_adb_dev.txt" >nul 2>&1

echo --------------------------------------------------
echo [OK] Установка завершена.
pause
goto menu
#>

