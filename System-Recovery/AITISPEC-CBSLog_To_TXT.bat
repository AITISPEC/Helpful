@echo off
chcp 65001 >nul
color a
title CBS Log to TXT
findstr /c:"[SR]" %windir%\Logs\CBS\CBS.log >"%userprofile%\Desktop\sfcdetails.txt"
echo Файл создан на рабочем столе: sfcdetails.txt
pause
