[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"
$scriptRoot = $PSScriptRoot
$updatePath = Join-Path $scriptRoot "update"

if (-not (Test-Path $updatePath)) {
    Write-Host "[ОШИБКА] Папка update не найдена рядом со скриптом!" -ForegroundColor Red
    Read-Host "Нажмите Enter для выхода"
    exit 1
}

# Функция быстрого слияния .txt файлов
function Merge-TextFiles {
    param($sourceDir, $destDir)
    if (-not (Test-Path $sourceDir)) { return }

    $files = Get-ChildItem -Path $sourceDir -Filter "*.txt"
    foreach ($f in $files) {
        $destFile = Join-Path $destDir $f.Name
        $newContent = Get-Content $f.FullName -Encoding UTF8
        
        # HashSet для O(1) поиска уникальных строк (работает мгновенно даже на 50к строк)
        $newSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($line in $newContent) { $null = $newSet.Add($line) }

        $uniqueOld = @()
        if (Test-Path $destFile) {
            $oldContent = Get-Content $destFile -Encoding UTF8
            foreach ($line in $oldContent) {
                if (-not $newSet.Contains($line)) { $uniqueOld += $line }
            }
        }

        $merged = @($newContent) + $uniqueOld
        Set-Content -Path $destFile -Value $merged -Encoding UTF8 -Force
        Write-Host "  -> $($f.Name)" -ForegroundColor Green
    }
}

Write-Host "====================" -ForegroundColor Cyan
Write-Host " НАЧАЛО ОБНОВЛЕНИЯ" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

Write-Host "[1/5] Объединяю текстовые списки..." -ForegroundColor Yellow
Merge-TextFiles -sourceDir (Join-Path $updatePath "lists") -destDir (Join-Path $scriptRoot "lists")
Merge-TextFiles -sourceDir (Join-Path $updatePath "utils") -destDir (Join-Path $scriptRoot "utils")

Write-Host "[2/5] Обновляю .bat файлы..." -ForegroundColor Yellow
Get-ChildItem -Path $updatePath -Filter "*.bat" | Where-Object Name -ne "update.bat" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $scriptRoot -Force -ErrorAction SilentlyContinue
    Write-Host "  -> $($_.Name)" -ForegroundColor Green
}

Write-Host "[3/5] Обновляю папку bin..." -ForegroundColor Yellow
$binSrc = Join-Path $updatePath "bin"
$binDst = Join-Path $scriptRoot "bin"
if (Test-Path $binSrc) {
    if (-not (Test-Path $binDst)) { New-Item -ItemType Directory -Path $binDst -Force | Out-Null }
    Copy-Item -Path "$binSrc\*" -Destination $binDst -Recurse -Force
    Write-Host "  -> bin\ (обновлено)" -ForegroundColor Green
}

Write-Host "[4/5] Обновляю test zapret.ps1..." -ForegroundColor Yellow
$ps1Src = Join-Path $updatePath "utils\test zapret.ps1"
if (Test-Path $ps1Src) {
    Copy-Item -Path $ps1Src -Destination (Join-Path $scriptRoot "utils") -Force
    Write-Host "  -> test zapret.ps1" -ForegroundColor Green
}

Write-Host "[5/5] Очистка временных файлов и папки update..." -ForegroundColor Yellow
$tempUpdate = Join-Path $scriptRoot "temp_update"
if (Test-Path $tempUpdate) { Remove-Item $tempUpdate -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path $updatePath) {
    Get-ChildItem -Path $updatePath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "  -> update очищена" -ForegroundColor Green
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " СПИСКИ ОБНОВЛЕНЫ. НОВЫЕ ФАЙЛЫ СКОПИРОВАНЫ!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Start-Sleep -Seconds 1
