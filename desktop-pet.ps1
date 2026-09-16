[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot
$pythonw = Join-Path $projectRoot "agent\.venv\Scripts\pythonw.exe"
$desktopPet = Join-Path $projectRoot "desktop_pet\arcana_desktop_pet.py"

if (-not (Test-Path -LiteralPath $pythonw)) {
    throw "Desktop pet dependencies are missing. Double-click setup.bat first."
}
if (-not (Test-Path -LiteralPath $desktopPet)) {
    throw "Desktop pet program was not found: $desktopPet"
}

Start-Process -FilePath $pythonw -ArgumentList @($desktopPet) -WorkingDirectory $projectRoot -WindowStyle Hidden
Write-Host "ARCANA desktop pet started. Click to open, drag to move, or right-click for settings." -ForegroundColor Green
