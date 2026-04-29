@echo off
chcp 65001 >nul
color a
title Firewall OFF
NetSh AdvFirewall Set AllProfiles State Off
echo Firewall выключен.
pause
