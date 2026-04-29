@echo off
chcp 65001 >nul
color a
title System Score
:menu
cls
echo Change:
echo.
echo 1 - Запустить проверку
echo 2 - Открыть папку с результатами (raw XML)
echo 3 - Показать результаты
echo.
set /p choice="Выберите пункт: "
if not defined choice goto menu
if "%choice%"=="1" goto start
if "%choice%"=="2" goto res
if "%choice%"=="3" goto parse
goto menu

:start
winsat formal -restart clean
echo Benchmark finished.
goto menu

:res
start %windir%\Performance\WinSAT\DataStore
exit

:parse
echo Поиск WinSAT Formal Assessment...
set "datastore=%windir%\Performance\WinSAT\DataStore"
pushd "%datastore%" 2>nul || (echo Folder not found & pause & goto menu)
for /f "delims=" %%i in ('dir /b /od "*Formal.Assessment*.WinSAT.xml" 2^>nul') do set "latest=%%i"
if "%latest%"=="" (
    echo No Formal.Assessment found. Trying any WinSAT.xml...
    for /f "delims=" %%i in ('dir /b /od "*.WinSAT.xml" 2^>nul') do set "latest=%%i"
)
popd
if "%latest%"=="" (echo No WinSAT results found. Run option 1 first. & pause & goto menu)
echo Парсинг %latest% ...
echo.
powershell -Command "$content = Get-Content '%datastore%\%latest%' -Raw; $start = $content.IndexOf('<WinSPR>'); if($start -lt 0){Write-Host 'WinSPR tag not found'; exit}; $end = $content.IndexOf('</WinSPR>', $start); if($end -lt 0){exit}; $spr = $content.Substring($start+8, $end-$start-8); $regex = [regex]'<([^>]+)>([^<]+)</\1>'; $matches = $regex.Matches($spr); Write-Host '======== WinSAT Scores ========'; foreach($m in $matches){ Write-Host ('{0,-25}: {1}' -f $m.Groups[1].Value, $m.Groups[2].Value) }"
echo.
pause
goto menu
