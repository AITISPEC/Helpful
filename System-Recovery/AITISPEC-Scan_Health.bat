@echo off
chcp 65001 >nul
color a
title Scan Health
pause
DISM /Online /Cleanup-Image /ScanHealth
pause
