[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot
$agentDirectory = Join-Path $projectRoot "agent"
$frontendDirectory = Join-Path $projectRoot "frontend"
$venvPython = Join-Path $agentDirectory ".venv\Scripts\python.exe"
$envFile = Join-Path $agentDirectory ".env"
$envExample = Join-Path $agentDirectory ".env.example"

function Resolve-CommandPath {
    param([string[]]$Names)
    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    return $null
}

function Assert-NativeSuccess {
    param([string]$Step, [int]$ExitCode)
    if ($ExitCode -ne 0) {
        throw "$Step failed with exit code $ExitCode. Review the messages above and run setup.ps1 again."
    }
}

$python = Resolve-CommandPath @("python.exe", "python")
$npm = Resolve-CommandPath @("npm.cmd", "npm")
if (-not $python) { throw "Python was not found. Install Python 3.10+ and enable Add Python to PATH." }
if (-not $npm) { throw "npm was not found. Install Node.js 20.19+ or 22.12+." }

Write-Host "[1/4] Creating the Python virtual environment..." -ForegroundColor Cyan
if (-not (Test-Path -LiteralPath $venvPython)) {
    & $python -m venv (Join-Path $agentDirectory ".venv")
    Assert-NativeSuccess "Creating the Python virtual environment" $LASTEXITCODE
}

# Some managed Python distributions can create a venv without pip. Repair it
# before installing dependencies instead of incorrectly reporting success.
& $venvPython -m pip --version *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "The virtual environment has no pip. Repairing it with ensurepip..." -ForegroundColor Yellow
    & $venvPython -m ensurepip --upgrade
    Assert-NativeSuccess "Installing pip into the virtual environment" $LASTEXITCODE
}

Write-Host "[2/4] Installing backend dependencies..." -ForegroundColor Cyan
& $venvPython -m pip install --upgrade pip
Assert-NativeSuccess "Upgrading pip" $LASTEXITCODE
& $venvPython -m pip install -r (Join-Path $agentDirectory "requirements.txt")
Assert-NativeSuccess "Installing backend dependencies" $LASTEXITCODE

Write-Host "[3/4] Installing and building the frontend..." -ForegroundColor Cyan
Push-Location $frontendDirectory
try {
    & $npm install
    Assert-NativeSuccess "Installing frontend dependencies" $LASTEXITCODE
    & $npm run build
    Assert-NativeSuccess "Building the frontend" $LASTEXITCODE
} finally {
    Pop-Location
}

Write-Host "[4/4] Preparing the environment file..." -ForegroundColor Cyan
if (-not (Test-Path -LiteralPath $envFile)) {
    Copy-Item -LiteralPath $envExample -Destination $envFile
}

Write-Host ""
Write-Host "Setup complete. Double-click start.bat to run the site and desktop pet." -ForegroundColor Green
Write-Host "To launch only the desktop pet, double-click desktop-pet.bat."
Write-Host "For the desktop-pet Mind, edit agent\.env and set MINDS_API_KEY plus MINDS_SPARK_ID."
