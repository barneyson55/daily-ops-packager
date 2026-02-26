param(
  [string]$Source = "config\app.sample.ini",
  [string]$Target = "config\app.ini",
  [switch]$Force
)

$base = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $base $Source
$targetPath = Join-Path $base $Target

if (-not (Test-Path $sourcePath)) {
  Write-Error "Source config not found: $sourcePath"
  exit 1
}

if ((Test-Path $targetPath) -and (-not $Force)) {
  Write-Host "Target already exists: $targetPath"
  Write-Host "Use -Force to overwrite."
  exit 0
}

$targetDir = Split-Path -Parent $targetPath
if (-not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

Copy-Item -Path $sourcePath -Destination $targetPath -Force
Write-Host "Created config: $targetPath"
