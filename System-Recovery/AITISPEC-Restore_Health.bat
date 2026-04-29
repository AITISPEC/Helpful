@echo off
chcp 65001 >nul
color a
title Restore Health
pause
DISM /Online /Cleanup-Image /RestoreHealth
pause
