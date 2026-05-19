<# : Choose-Your-Language
@echo off
color a
chcp 65001 > nul
echo =========================================
echo       PYTHON PATH FIXER BY AITISPEC
echo =========================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Get-Content '%~f0' -Raw)"
exit /b
#>

# --- ДАЛЬШЕ ИДЕТ ЧИСТЫЙ POWERSHELL КОД ---
$ErrorActionPreference = "Continue"

try {
    Write-Host "[1/3] Scanning system for all Python installations..." -ForegroundColor Cyan

    $searchRoots = @(
        "$env:USERPROFILE\AppData\Local\Programs\Python",
        "$env:USERPROFILE\AppData\Local\Python",
        "C:\Program Files\Python*",
        "C:\Program Files (x86)\Python*",
        "C:\Python*"
    )

    $pythonPaths = @()

    foreach ($root in $searchRoots) {
        if (Test-Path $root -ErrorAction SilentlyContinue) {
            $foundFiles = Get-ChildItem -Path $root -Filter "python.exe" -Recurse -Depth 2 -ErrorAction SilentlyContinue
            foreach ($file in $foundFiles) {
                $dir = $file.DirectoryName
                if ($dir -notlike "*WindowsApps*" -and $pythonPaths -notcontains $dir) {
                    $pythonPaths += $dir
                }
            }
        }
    }

    if ($pythonPaths.Count -eq 0) {
        $regPaths = @("HKCU:\Software\Python\PythonCore", "HKLM:\Software\Python\PythonCore")
        foreach ($reg in $regPaths) {
            if (Test-Path $reg -ErrorAction SilentlyContinue) {
                $versions = Get-ChildItem -Path $reg -ErrorAction SilentlyContinue
                foreach ($ver in $versions) {
                    $installProps = Get-ItemProperty -Path "$($ver.PSPath)\InstallPath" -ErrorAction SilentlyContinue
                    if ($installProps -and $installProps.'(Default)') {
                        $installPath = $installProps.'(Default)'.TrimEnd([char]92)
                        if (Test-Path $installPath -ErrorAction SilentlyContinue) {
                            $pythonPaths += $installPath
                        }
                    }
                }
            }
        }
    }

    if ($pythonPaths.Count -eq 0) {
        Write-Host "CRITICAL ERROR: No Python installation found on this PC!" -ForegroundColor Red
        Write-Host "Please install Python from python.org first." -ForegroundColor Yellow
        Write-Host "`nPress any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }

    $pathsToInject = @()
    foreach ($pyPath in $pythonPaths) {
        $pathsToInject += $pyPath
        $binPath = Join-Path $pyPath "bin"
        $scriptsPath = Join-Path $pyPath "Scripts"

        if (Test-Path $binPath -ErrorAction SilentlyContinue) { $pathsToInject += $binPath }
        if (Test-Path $scriptsPath -ErrorAction SilentlyContinue) { $pathsToInject += $scriptsPath }
    }

    Write-Host "Detected working Python directories:" -ForegroundColor Gray
    foreach ($p in $pathsToInject) { Write-Host " -> $p" -ForegroundColor Green }

    Write-Host "`n[2/3] Resolving and repairing PATH priority..." -ForegroundColor Cyan

    $rawUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $rawUserPath) { $rawUserPath = "" }

    $currentPaths = ($rawUserPath -split ';') | Where-Object { $_ -and $_.Trim() -ne "" }

    $cleanPaths = @()
    foreach ($cp in $currentPaths) {
        $normalizedCp = $cp.TrimEnd([char]92)
        $isPythonPath = $false
        foreach ($pip in $pathsToInject) {
            if ($normalizedCp -ieq $pip.TrimEnd([char]92)) { $isPythonPath = $true }
        }
        if (-not $isPythonPath) { $cleanPaths += $cp }
    }

    $newPathList = $pathsToInject + $cleanPaths
    $newPathString = $newPathList -join ';'

    [Environment]::SetEnvironmentVariable("Path", $newPathString, "User")
    Write-Host "PATH successfully rebuilt and repaired!" -ForegroundColor Green

    Write-Host "`n[3/3] Deleting Microsoft Store execution links..." -ForegroundColor Cyan
    $appAppsFolder = "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"

    $storeFiles = @("python.exe", "python3.exe", "pip.exe", "pip3.exe")
    foreach ($file in $storeFiles) {
        $targetFile = Join-Path $appAppsFolder $file
        if (Test-Path $targetFile -ErrorAction SilentlyContinue) {
            Remove-Item $targetFile -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    Write-Host "`nFIX COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "PLEASE RESTART YOUR TERMINAL / CONSOLE TO APPLY CHANGES." -ForegroundColor Yellow

} catch {
    Write-Host "`nUnexpected critical script error: $_" -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
