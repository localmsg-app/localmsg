$ErrorActionPreference = "Stop"

$repo = "sindus/localmsg"
$url = "https://github.com/$repo/releases/latest/download/localmsg-setup.exe"
$out = Join-Path $env:TEMP "localmsg-setup.exe"

Write-Host "Téléchargement de LocalMsg..."
Invoke-WebRequest -Uri $url -OutFile $out

Write-Host "Installation..."
Start-Process -FilePath $out -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES" -Wait

Write-Host "LocalMsg installé."
