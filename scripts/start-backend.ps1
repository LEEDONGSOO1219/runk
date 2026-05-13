Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root "backend"
Set-Location $backend

function Get-PythonCommand {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        return , @("python")
    }

    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($py) {
        return , @("py", "-3.12")
    }

    throw "Python 3.12 is required. Install Python or add it to PATH before starting the backend."
}

if (!(Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
}

$venvPython = Join-Path $backend ".venv\Scripts\python.exe"
$venvReady = $false
if (Test-Path $venvPython) {
    & $venvPython --version *> $null
    $venvReady = $LASTEXITCODE -eq 0
}

if (!$venvReady) {
    $pythonCommand = Get-PythonCommand
    $pythonExe = $pythonCommand[0]
    if ($pythonCommand.Length -eq 1) {
        & $pythonExe -m venv --clear .venv
    }
    else {
        $pythonVersionArg = $pythonCommand[1]
        & $pythonExe $pythonVersionArg -m venv --clear .venv
    }
}

& $venvPython -m pip install -r requirements.txt
& $venvPython -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
