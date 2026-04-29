@echo off
chcp 65001 >nul
color a
title Windows Store and Apps Reset
openfiles > NUL 2>&1
if NOT %ERRORLEVEL% EQU 0 (
    echo Требуются права администратора!
    pause
    exit
)

echo Stop Settings and Windows Store...
taskkill /f /im SystemSettings.exe 2>nul
taskkill /f /im WinStore.Mobile.exe 2>nul

echo Stop Services...
net stop wuauserv 2>nul
net stop AppIDSvc 2>nul
sc config "cryptSvc" start=disabled
net stop cryptSvc 2>nul

echo Deleting catroot2.old folder if exist...
rd /s /q %systemroot%\System32\catroot2.old 2>nul
rename %systemroot%\System32\catroot2 catroot2.old 2>nul

net stop bits 2>nul
net stop msiserver 2>nul

echo Deleting SoftwareDistribution.old folder if exist...
rd /s /q %systemroot%\SoftwareDistribution.old 2>nul
rename %systemroot%\SoftwareDistribution SoftwareDistribution.old 2>nul

echo Deleting SettingSync registry key...
reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" /f 2>nul

echo Deleting SettingSync folder if exist...
rd /s /q "%userprofile%\AppData\Local\Microsoft\Windows\SettingSync.old" 2>nul
attrib -h -s "%userprofile%\AppData\Local\Microsoft\Windows\SettingSync" /d /s 2>nul
rename "%userprofile%\AppData\Local\Microsoft\Windows\SettingSync" SettingSync.old 2>nul

echo Restore default CurrentVersion and CSDVersion registry keys...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CSDVersion" /f 2>nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "CurrentVersion" /t REG_SZ /d "6.3" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Windows" /v "CSDVersion" /t REG_DWORD /d "00000000" /f

echo Restore Windows Store settings...
wsreset.exe
timeout /t 30 /nobreak >nul

PowerShell.exe -ExecutionPolicy Unrestricted -command "Remove-Item $env:localappdata\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\*.json" 2>nul
PowerShell.exe -ExecutionPolicy Unrestricted -command "(Get-AppXPackage -AllUsers |Where-Object {$_.InstallLocation -like '*SystemApps*'} | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppXManifest.xml\"})" 2>nul

echo Restore Start menu...
taskkill /f /im explorer.exe 2>nul
taskkill /f /im ShellExperienceHost.exe 2>nul
PowerShell.exe -ExecutionPolicy Unrestricted -command "(Get-AppXPackage -AllUsers |Where-Object {$_.InstallLocation -like '*shellexperience*'} | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\AppxManifest.xml\"})" 2>nul
start explorer.exe

echo Start services...
net start wuauserv 2>nul
sc config "cryptSvc" start=auto
net start bits 2>nul
net start msiserver 2>nul

echo.
echo Done.
pause
exit
