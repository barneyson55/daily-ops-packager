param(
  [string]$Config = "config\\app.ini",
  [string]$AhkExe = ""
)

$base = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $base $Config
if (-not (Test-Path $configPath)) {
  Write-Error "Config not found: $configPath"
  exit 1
}

$checkScript = Join-Path $PSScriptRoot "CheckPrereqs.ps1"
if (-not (Test-Path $checkScript)) {
  Write-Error "CheckPrereqs.ps1 not found: $checkScript"
  exit 1
}

Write-Host "Running prereq check..."
& powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript -Config $Config
if ($LASTEXITCODE -ne 0) {
  Write-Error "Prereq check failed."
  exit $LASTEXITCODE
}

if (-not $AhkExe) {
  $cmd = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
  if (-not $cmd) { $cmd = Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue }
  if ($cmd) { $AhkExe = $cmd.Source }
}

if (-not $AhkExe) {
  Write-Error "AutoHotkey not found in PATH. Pass -AhkExe C:\\Path\\To\\AutoHotkey64.exe"
  exit 1
}

$ahkScript = Join-Path $base "src\\OneClickBackup.ahk"
if (-not (Test-Path $ahkScript)) {
  Write-Error "AHK script not found: $ahkScript"
  exit 1
}

Write-Host "Running dry-run..."
& $AhkExe $ahkScript --config $Config --dry-run
$code = $LASTEXITCODE
if ($code -ne 0) {
  Write-Error "Dry-run failed with exit code $code"
  exit $code
}

Write-Host "Smoke test OK."
