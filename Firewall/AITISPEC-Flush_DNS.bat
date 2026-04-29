@echo off
chcp 65001 >nul
color a
title Flush DNS
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /flushdns
echo Готово.
pause
