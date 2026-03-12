param(
  [string]$Config = "config\fixtures\readiness.pass.ini",
  [string]$AhkExe = ""
)

$base = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $base $Config
$defaultFixtureConfig = 'config\fixtures\readiness.pass.ini'
$usingDefaultFixture = ($Config -replace '/', '\') -ieq $defaultFixtureConfig
$originalReadinessZipPass = [Environment]::GetEnvironmentVariable('READINESS_ZIP_PASS', 'Process')
$originalReadinessSmtpPass = [Environment]::GetEnvironmentVariable('READINESS_SMTP_PASS', 'Process')

try {
  if ($usingDefaultFixture) {
    if ([string]::IsNullOrWhiteSpace($env:READINESS_ZIP_PASS)) {
      $env:READINESS_ZIP_PASS = 'smoke-fixture-zip-pass'
    }

    if ([string]::IsNullOrWhiteSpace($env:READINESS_SMTP_PASS)) {
      $env:READINESS_SMTP_PASS = 'smoke-fixture-smtp-pass'
    }

    Write-Host "Using repo-local readiness fixture: $Config"
  }

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
    Write-Error "AutoHotkey not found in PATH. Pass -AhkExe C:\Path\To\AutoHotkey64.exe"
    exit 1
  }

  $ahkScript = Join-Path $base "src\OneClickBackup.ahk"
  if (-not (Test-Path $ahkScript)) {
    Write-Error "AHK script not found: $ahkScript"
    exit 1
  }

  Write-Host "Running dry-run..."
  & $AhkExe '/ErrorStdOut=UTF-8' $ahkScript --config $Config --dry-run
  $code = $LASTEXITCODE
  if ($code -ne 0) {
    Write-Error "Dry-run failed with exit code $code"
    exit $code
  }

  Write-Host "Smoke test OK."
}
finally {
  if ($usingDefaultFixture) {
    if ($null -eq $originalReadinessZipPass) {
      Remove-Item Env:READINESS_ZIP_PASS -ErrorAction SilentlyContinue
    }
    else {
      $env:READINESS_ZIP_PASS = $originalReadinessZipPass
    }

    if ($null -eq $originalReadinessSmtpPass) {
      Remove-Item Env:READINESS_SMTP_PASS -ErrorAction SilentlyContinue
    }
    else {
      $env:READINESS_SMTP_PASS = $originalReadinessSmtpPass
    }
  }
}
