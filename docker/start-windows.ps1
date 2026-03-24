$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

Push-Location $repoRoot
try {
    docker version | Out-Null
    docker compose up -d --build
    docker compose ps
}
catch {
    throw "Docker daemon is unavailable. Start Docker Desktop, switch to Linux containers, then rerun this script.`n$($_.Exception.Message)"
}
finally {
    Pop-Location
}
