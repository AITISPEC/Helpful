@echo off
chcp 65001 >nul
color a
title Create Shortcut

if "%1"=="" (
    echo Перетащите .exe файл на этот ярлык для создания ярлыка.
    pause
    exit
)

set "target_path=%~1"
for %%F in ("%target_path%") do set "filename=%%~nF"
set "desktop=%USERPROFILE%\Desktop"
set "shortcut_name=%filename%"
set "shortcut_full=%desktop%\%shortcut_name%.lnk"

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcut_full%');$s.TargetPath='%target_path%';$s.Save()"

echo Создан ярлык: "%shortcut_full%"

echo %shortcut_name% | findstr /i "Ярлык" >nul
if %errorlevel%==0 (
    set "new_name=%shortcut_name:Ярлык=%"
    for /f "tokens=* delims= " %%a in ("%new_name%") do set "new_name=%%a"
    ren "%shortcut_full%" "%new_name%.lnk" 2>nul
    echo Переименованный ярлык: "%new_name%.lnk"
) else (
    echo Название ярлыка не содержит слово "Ярлык".
)
pause
