@echo off
chcp 65001 >nul
color a
title ChkDsk
echo Запуск chkdsk /f /r. Проверка диска будет выполнена при следующей перезагрузке.
pause
chkdsk /f /r
pause
