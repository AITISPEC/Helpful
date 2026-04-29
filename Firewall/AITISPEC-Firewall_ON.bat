@echo off
chcp 65001 >nul
color a
title Firewall ON
NetSh AdvFirewall Set AllProfiles State On
echo Firewall включён.
pause
