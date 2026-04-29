@echo off
chcp 65001 >nul
color a
title Restart TP-Link
%1 start "" /min cmd /c "%~f0" :& exit/b
:loop
cls
timeout /t 30
ping -n 1 8.8.8.8 && goto loop || goto restart_interface
:restart_interface
netsh interface set interface name="TP-Link" admin=DISABLED
netsh interface set interface name="TP-Link" admin=ENABLED
goto loop
