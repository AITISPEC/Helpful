@echo off
chcp 65001 >nul
color a
title Block EXE
setlocal enableextensions
cd /d "%~dp0"
for /R %%a in (*.exe) do (
    netsh advfirewall firewall add rule name="Blocked with Batchfile %%a" dir=out program="%%a" action=block
)
pause
