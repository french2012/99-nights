<#
PowerShell downloader: downloads admin-scripts.zip and extracts it.
Run in PowerShell (Windows):
  .\download_admin.ps1
#>
$ErrorActionPreference = 'Stop'

$out = "admin-scripts.zip"
$dir = "admin-scripts"
$url = "https://github.com/french2012/99-nights/raw/main/admin-scripts.zip"

Write-Host "Downloading admin scripts from: $url"
try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing
} catch {
    Write-Error "Download failed: $_"
    exit 1
}

Write-Host "Extracting $out to $dir\"
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($out, $dir)
} catch {
    Write-Warning "Unable to use .NET zip extraction, attempting Expand-Archive"
    try {
        Expand-Archive -LiteralPath $out -DestinationPath $dir -Force
    } catch {
        Write-Error "Extraction failed: $_"
        exit 2
    }
}

Write-Host "Done. Files are in .\$dir\roblox-dev-admin"
