<#
.SYNOPSIS
    Создание junction-ссылки (символической) с автоматическим перемещением содержимого.
.DESCRIPTION
    Переносит файлы из исходной папки в подпапку целевой (с именем исходной) и создаёт ссылку.
    Имеет защиту от системных папок и ведёт лог.
.NOTES
    Требуются права администратора. Запуск автоматически повышает привилегии.
#>

# ===== ЛОГИРОВАНИЕ =====
$logFile = Join-Path $PSScriptRoot "JLink.log"
try {
    Start-Transcript -Path $logFile -Append -Force | Out-Null
} catch {
    # Если не можем писать рядом со скриптом, пишем в TEMP
    $logFile = Join-Path $env:TEMP "JLink.log"
    Start-Transcript -Path $logFile -Append -Force | Out-Null
}

# ===== ПРИНУДИТЕЛЬНЫЙ ЗАПУСК ОТ АДМИНИСТРАТОРА =====
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "🚀 Запуск от имени администратора..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ===== ПОДГОНЯЕМ РАЗМЕР ОКНА КОНСОЛИ =====
try {
    $buf = $Host.UI.RawUI.BufferSize
    $buf.Width = 120
    $Host.UI.RawUI.BufferSize = $buf
    $win = $Host.UI.RawUI.WindowSize
    $win.Width = 75
    $win.Height = 30
    $Host.UI.RawUI.WindowSize = $win
} catch { }

Clear-Host
Write-Host @"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║     ██     ████   ██████   ████    ████    █████    █████    █████   ║
║    ████     ██      ██      ██    ██       ██  ██   ██       ██      ║
║   ██  ██    ██      ██      ██     ████    █████    █████    ██      ║
║   ██████    ██      ██      ██        ██   ██       ██       ██      ║
║   ██  ██   ████     ██     ████    ████    ██       █████    █████   ║
║                                                                      ║
║                    JUNCTION LINK CREATOR v1.0.1                      ║
╚══════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "`nSelect language / Выберите язык:" -ForegroundColor Yellow
Write-Host "  1 - English" -ForegroundColor White
Write-Host "  2 - Русский" -ForegroundColor White
$langChoice = Read-Host "Enter 1 or 2 / Введите 1 или 2"

if ($langChoice -eq "1") {
    $lang = "EN"
} else {
    $lang = "RU"
}

$strings = @{
    RU = @{
        Step1 = "📂 Шаг 1: Выбор исходной папки (где будет симлинк)"
        Step2 = "📂 Шаг 2: Выбор целевой папки (куда переместить файлы)"
        SelectSourceTitle = "ВЫБЕРИТЕ ИСХОДНУЮ ПАПКУ"
        SelectTargetTitle = "ВЫБЕРИТЕ ЦЕЛЕВУЮ ПАПКУ (на другом диске)"
        CancelMsg = "❌ Отменено пользователем."
        SourceNotEmptyTitle = "Папка не пуста"
        SourceNotEmptyMsg = "Исходная папка содержит файлы. Переместить их в целевую автоматически?"
        MovingFiles = "📦 Перемещение файлов..."
        MovingProgress = "Перемещение файлов"
        ProgressStatus = "{0} из {1} ({2}%)"
        FilesMoved = "✅ Файлы перемещены успешно."
        CancelNoLink = "❌ Отменено. Нельзя создать ссылку поверх существующих файлов."
        CreatingJunction = "`n🔗 Создание junction-ссылки..."
        SuccessLink = "✅ Ссылка успешно создана!"
        SuccessSource = "   Исходная папка: "
        SuccessTarget = "   Указывает на:   "
        SuccessMessageBox = "✅ УСПЕХ!`n`n📁 Исходная папка:`n{0}`n`n🔗 Ссылка ведёт в:`n{1}"
        SuccessTitle = "Junction Link Created"
        ErrorPrefix = "❌ Ошибка: "
        ErrorMessageBox = "❌ НЕ УДАЛОСЬ СОЗДАТЬ ССЫЛКУ!`n`n{0}"
        ErrorTitle = "Ошибка"
        Finished = "`n🎉 Работа завершена."
        SubfolderExistsTitle = "Подпапка существует"
        SubfolderExistsMsg = "Папка '{0}' уже существует в целевой директории.`nПерезаписать её содержимое? (Все файлы будут заменены)"
        SystemFolderError = "❌ ЗАПРЕЩЕНО! Нельзя переносить системные папки Windows.`nСписок запрещённых папок: Windows, Program Files, Program Files (x86), Users."
    }
    EN = @{
        Step1 = "📂 Step 1: Select source folder (where symlink will be)"
        Step2 = "📂 Step 2: Select target folder (where files will be moved)"
        SelectSourceTitle = "SELECT SOURCE FOLDER"
        SelectTargetTitle = "SELECT TARGET FOLDER (on another drive)"
        CancelMsg = "❌ Canceled by user."
        SourceNotEmptyTitle = "Folder not empty"
        SourceNotEmptyMsg = "Source folder contains files. Move them to target automatically?"
        MovingFiles = "📦 Moving files..."
        MovingProgress = "Moving files"
        ProgressStatus = "{0} of {1} ({2}%)"
        FilesMoved = "✅ Files moved successfully."
        CancelNoLink = "❌ Canceled. Cannot create link over existing files."
        CreatingJunction = "`n🔗 Creating junction link..."
        SuccessLink = "✅ Link successfully created!"
        SuccessSource = "   Source folder: "
        SuccessTarget = "   Points to:     "
        SuccessMessageBox = "✅ SUCCESS!`n`n📁 Source folder:`n{0}`n`n🔗 Link points to:`n{1}"
        SuccessTitle = "Junction Link Created"
        ErrorPrefix = "❌ Error: "
        ErrorMessageBox = "❌ FAILED TO CREATE LINK!`n`n{0}"
        ErrorTitle = "Error"
        Finished = "`n🎉 Work completed."
        SubfolderExistsTitle = "Subfolder exists"
        SubfolderExistsMsg = "Folder '{0}' already exists in target location.`nOverwrite its contents? (All files will be replaced)"
        SystemFolderError = "❌ FORBIDDEN! Cannot move Windows system folders.`nBlocked list: Windows, Program Files, Program Files (x86), Users."
    }
}

$msg = $strings[$lang]

function Play-SuccessSound {
    [System.Media.SystemSounds]::Asterisk.Play()
}
function Play-ErrorSound {
    [System.Media.SystemSounds]::Hand.Play()
}
function Play-QuestionSound {
    [System.Media.SystemSounds]::Question.Play()
}

Add-Type -AssemblyName System.Windows.Forms
$FB = New-Object System.Windows.Forms.FolderBrowserDialog

function Select-Folder($Title) {
    $FB.Description = $Title
    if($FB.ShowDialog() -ne "OK") {
        Write-Host $msg.CancelMsg -ForegroundColor Red
        Play-ErrorSound
        exit
    }
    return $FB.SelectedPath
}

Write-Host "`n$($msg.Step1)" -ForegroundColor Yellow
$source = Select-Folder $msg.SelectSourceTitle

# ===== ЗАЩИТА ОТ СИСТЕМНЫХ ПАПОК =====
$systemFolders = @(
    "$env:WINDIR",
    "$env:ProgramFiles",
    "${env:ProgramFiles(x86)}",
    "$env:USERPROFILE"
)
# Нормализуем пути (убираем завершающий слеш)
$sourceNormalized = $source.TrimEnd('\')
if ($systemFolders | Where-Object { $sourceNormalized -eq $_.TrimEnd('\') }) {
    Write-Host "`n$($msg.SystemFolderError)" -ForegroundColor Red
    Play-ErrorSound
    [System.Windows.Forms.MessageBox]::Show($msg.SystemFolderError, $msg.ErrorTitle, "OK", "Error")
    exit
}

Write-Host "$($msg.Step2)" -ForegroundColor Yellow
$target = Select-Folder $msg.SelectTargetTitle

# ===== ОСНОВНАЯ ЛОГИКА (ВАРИАНТ 3) =====
$sourceFolderName = Split-Path $source -Leaf
$targetSubfolder = Join-Path $target $sourceFolderName

Write-Host "`n📝 Лог сохраняется в: $logFile" -ForegroundColor DarkGray

if (Test-Path "$source\*") {
    Write-Host "`n⚠️ $(if ($lang -eq "RU") { "Исходная папка не пуста." } else { "Source folder is not empty." })" -ForegroundColor Yellow
    Play-QuestionSound
    $result = [System.Windows.Forms.MessageBox]::Show($msg.SourceNotEmptyMsg, $msg.SourceNotEmptyTitle, "YesNoCancel", "Question")

    if ($result -eq "Yes") {
        if (Test-Path $targetSubfolder) {
            $overwrite = [System.Windows.Forms.MessageBox]::Show(
                ($msg.SubfolderExistsMsg -f $sourceFolderName),
                $msg.SubfolderExistsTitle,
                "YesNo",
                "Warning"
            )
            if ($overwrite -eq "No") {
                Write-Host $msg.CancelMsg -ForegroundColor Red
                Play-ErrorSound
                exit
            }
            Remove-Item $targetSubfolder -Recurse -Force -ErrorAction SilentlyContinue
        }

        New-Item -ItemType Directory -Path $targetSubfolder | Out-Null
        Write-Host $msg.MovingFiles -ForegroundColor Cyan

        $files = Get-ChildItem -Path $source -Recurse
        if ($files.Count -gt 0) {
            for ($i = 0; $i -lt $files.Count; $i++) {
                $percent = [math]::Round(($i / $files.Count) * 100)
                $status = $msg.ProgressStatus -f ($i+1), $files.Count, $percent
                Write-Progress -Activity $msg.MovingProgress -Status $status -PercentComplete $percent
                Move-Item -Path $files[$i].FullName -Destination $targetSubfolder -Force -ErrorAction SilentlyContinue
            }
            Write-Progress -Activity $msg.MovingProgress -Completed
        } else {
            Get-ChildItem -Path $source | Move-Item -Destination $targetSubfolder -Force
        }

        Remove-Item $source -Recurse -Force
        Write-Host $msg.FilesMoved -ForegroundColor Green
    } elseif ($result -eq "No") {
        Write-Host $msg.CancelNoLink -ForegroundColor Red
        Play-ErrorSound
        pause
        exit
    } else {
        Write-Host $msg.CancelMsg -ForegroundColor Red
        Play-ErrorSound
        exit
    }
} else {
    Write-Host "`n📂 $(if ($lang -eq "RU") { "Исходная папка пуста. Создаётся ссылка на новую подпапку." } else { "Source folder is empty. Creating link to new subfolder." })" -ForegroundColor Cyan
    if (Test-Path $source) {
        Remove-Item $source -Force -ErrorAction SilentlyContinue
    }
    if (-not (Test-Path $targetSubfolder)) {
        New-Item -ItemType Directory -Path $targetSubfolder | Out-Null
    }
}

Write-Host $msg.CreatingJunction -ForegroundColor Cyan
try {
    $output = cmd /c mklink /J "$source" "$targetSubfolder" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host $msg.SuccessLink -ForegroundColor Green
        Write-Host "$($msg.SuccessSource)$source" -ForegroundColor White
        Write-Host "$($msg.SuccessTarget)$targetSubfolder" -ForegroundColor White

        Play-SuccessSound
        [System.Windows.Forms.MessageBox]::Show(
            ($msg.SuccessMessageBox -f $source, $targetSubfolder),
            $msg.SuccessTitle,
            "OK",
            "Information"
        )
    } else {
        throw $output
    }
} catch {
    Write-Host "$($msg.ErrorPrefix)$_" -ForegroundColor Red
    Play-ErrorSound
    [System.Windows.Forms.MessageBox]::Show(
        ($msg.ErrorMessageBox -f $_.Exception.Message),
        $msg.ErrorTitle,
        "OK",
        "Error"
    )
}

Write-Host $msg.Finished -ForegroundColor Yellow
Write-Host "📄 Полный лог: $logFile" -ForegroundColor DarkGray
Stop-Transcript | Out-Null
pause > $null
