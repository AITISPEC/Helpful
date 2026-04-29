@echo off
chcp 65001 >nul
color a
title Repair Services Windows 11

:: Проверка прав администратора
openfiles > NUL 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Требуются права администратора!
    pause
    exit /b 1
)
echo Запущено с правами администратора.
echo.

setlocal enabledelayedexpansion

:: ANSI color codes (работают в Windows 10/11)
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "YELLOW=%ESC%[33m"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

:: Список служб (сокращён для примера, но можно полный)
set SVC_LIST=^
CryptSvc DcomLaunch Dhcp Dnscache EventLog PlugPlay Power ProfSvc RpcSs SamSs Themes Winmgmt wuauserv ^
ADPSvc ALG AppIDSvc Appinfo AppMgmt AppReadiness AppVClient AppXSvc ApxSvc AssignedAccessManagerSvc ^
AudioEndpointBuilder Audiosrv autotimesvc AxInstSV BDESVC BFE BITS BrokerInfrastructure BTAGService ^
BthAvctpSvc bthserv camsvc CDPSvc CertPropSvc ClipSVC cloudidsvc COMSysApp CoreMessagingRegistrar ^
CscService dcsvc defragsvc DeviceAssociationService DeviceInstall DevQueryBroker diagsvc DiagTrack ^
DialogBlockingService DispBrokerDesktopSvc DisplayEnhancementService DmEnrollmentSvc dmwappushservice DoSvc ^
dot3svc DPS DsmSvc DsSvc DusmSvc EapHost EFS embeddedmode EntAppSvc EventSystem fdPHost FDResPub ^
fhsvc FontCache FontCache3.0.0.0 FrameServer FrameServerMonitor FvSvc GameInputSvc gpsvc GraphicsPerfSvc ^
hidserv hpatchmon HvHost icssvc IKEEXT InstallService InventorySvc iphlpsvc IpxlatCfgSvc KeyIso KtmRm ^
LanmanServer LanmanWorkstation lfsvc LicenseManager lltdsvc lmhosts LocalKdc LSM LxpSvc MapsBroker McmSvc ^
McpManagementService MDCoreSvc MicrosoftEdgeElevationService midisrv mpssvc MSDTC MSiSCSI msiserver ^
MsKeyboardFilter NaturalAuthentication NcaSvc NcbService NcdAutoSetup Netlogon Netman netprofm NetSetupSvc ^
NetTcpPortSharing NgcCtnrSvc NgcSvc NlaSvc nsi PcaSvc PeerDistSvc perceptionsimulation PerfHost PhoneSvc ^
pla PolicyAgent PrintDeviceConfigurationService PrintNotify PrintScanBrokerService PushToInstall QWAVE RasAuto ^
RasMan refsdedupsvc RemoteAccess RemoteRegistry RetailDemo RmSvc RpcEptMapper RpcLocator Schedule SCardSvr ^
ScDeviceEnum SCPolicySvc SDRSVC seclogon SecurityHealthService SEMgrSvc SENS Sense SensorDataService ^
SensorService SensrSvc SessionEnv SharedAccess ShellHWDetection shpamsvc smphost SmsRouter SNMPTrap Spooler ^
sppsvc SSDPSRV SstpSvc StateRepository StiSvc StorSvc svsvc swprv SysMain SystemEventsBroker TapiSrv ^
TermService TextInputManagementService TieringEngineService TimeBrokerSvc TokenBroker TrkWks TroubleshootingSvc ^
TrustedInstaller tzautoupdate UevAgentService UmRdpService upnphost UserManager UsoSvc VaultSvc vds ^
vmicguestinterface vmicheartbeat vmickvpexchange vmicrdv vmicshutdown vmictimesync vmicvmsession vmicvss VSS ^
W32Time WaaSMedicSvc WalletService WarpJITSvc wbengine WbioSrvc Wcmsvc wcncsvc WdiServiceHost WdiSystemHost ^
WdNisSvc WebClient webthreatdefsvc Wecsvc WEPHOSTSVC wercplsupport WerSvc WFDSConMgrSvc whesvc WiaRpc ^
WinDefend WinHttpAutoProxySvc WinRM wisvc WlanSvc wlidsvc wlpasvc WManSvc wmiApSrv WMPNetworkSvc ^
workfolderssvc WpcMonSvc WPDBusEnum WpnService WSAIFabricSvc wscsvc WSearch wuqisvc WwanSvc XblAuthManager ^
XblGameSave XboxGipSvc XboxNetApiSvc

echo [INFO] Установка типа запуска AUTO и запуск служб...
echo.

for %%s in (%SVC_LIST%) do (
    :: Установить автозапуск (тихо)
    sc config "%%s" start= auto >nul 2>&1
    :: Запуск службы
    sc start "%%s" >nul 2>&1
    if !errorlevel! equ 1056 (
        echo !YELLOW![%%s] уже запущена!RESET!
    ) else if !errorlevel! equ 0 (
        echo !GREEN![%%s] запущена!RESET!
    ) else (
        echo !RED![%%s] ошибка !errorlevel!!RESET!
    )
)

echo.
echo !GREEN!Готово.!RESET!
pause
