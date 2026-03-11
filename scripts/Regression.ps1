param(
  [string]$SmokeConfig = "config\fixtures\readiness.pass.ini",
  [string]$AhkExe = ""
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$base = Split-Path -Parent $PSScriptRoot
$checkHeadlessScript = Join-Path $PSScriptRoot 'CheckHeadlessDefault.ps1'
$checkPrereqsScript = Join-Path $PSScriptRoot 'CheckPrereqs.ps1'
$smokeScript = Join-Path $PSScriptRoot 'SmokeTest.ps1'
$passConfig = 'config\fixtures\readiness.pass.ini'
$failWatchConfig = 'config\fixtures\readiness.fail-watchdir.ini'
$failEmailConfig = 'config\fixtures\readiness.fail-email.ini'

$script:PowerShellExe = (Get-Process -Id $PID).Path
if ([string]::IsNullOrWhiteSpace($script:PowerShellExe)) {
  $script:PowerShellExe = 'powershell.exe'
}

$script:CommonPowerShellArgs = @('-NoProfile')
if ($env:OS -eq 'Windows_NT') {
  $script:CommonPowerShellArgs += @('-ExecutionPolicy', 'Bypass')
}

function Invoke-PowerShellStep {
  param(
    [string]$Name,
    [string]$ScriptPath,
    [hashtable]$Arguments = @{},
    [int]$ExpectedExitCode = 0,
    [string[]]$ExpectedOutput = @()
  )

  if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
    throw "Script not found for step '$Name': $ScriptPath"
  }

  $argList = @()
  $argList += $script:CommonPowerShellArgs
  $argList += @('-File', $ScriptPath)

  foreach ($entry in ($Arguments.GetEnumerator() | Sort-Object Key)) {
    $argList += "-$($entry.Key)"
    if ($null -ne $entry.Value -and $entry.Value -ne '') {
      $argList += [string]$entry.Value
    }
  }

  Write-Host "==> $Name"
  $output = & $script:PowerShellExe @argList 2>&1
  $exitCode = $LASTEXITCODE
  $text = ($output | Out-String).Trim()

  if ($text) {
    Write-Host $text
  }

  if ($exitCode -ne $ExpectedExitCode) {
    throw "Step '$Name' exited $exitCode (expected $ExpectedExitCode)."
  }

  foreach ($expected in $ExpectedOutput) {
    if ($expected -and $text -notmatch [regex]::Escape($expected)) {
      throw "Step '$Name' did not emit expected text: $expected"
    }
  }
}

$originalZipPass = [Environment]::GetEnvironmentVariable('READINESS_ZIP_PASS', 'Process')
$originalSmtpPass = [Environment]::GetEnvironmentVariable('READINESS_SMTP_PASS', 'Process')

try {
  if ([string]::IsNullOrWhiteSpace($env:READINESS_ZIP_PASS)) {
    $env:READINESS_ZIP_PASS = 'regression-fixture-zip-pass'
  }

  if ([string]::IsNullOrWhiteSpace($env:READINESS_SMTP_PASS)) {
    $env:READINESS_SMTP_PASS = 'regression-fixture-smtp-pass'
  }

  Invoke-PowerShellStep -Name 'Static headless default guard' -ScriptPath $checkHeadlessScript -ExpectedOutput 'Headless default guard OK.'
  Invoke-PowerShellStep -Name 'Readiness pass fixture' -ScriptPath $checkPrereqsScript -Arguments @{ Config = $passConfig } -ExpectedOutput 'All prerequisites look OK.'
  Invoke-PowerShellStep -Name 'Readiness fail fixture (missing watchDir)' -ScriptPath $checkPrereqsScript -Arguments @{ Config = $failWatchConfig } -ExpectedExitCode 1 -ExpectedOutput 'watchDir not found'
  Invoke-PowerShellStep -Name 'Readiness fail fixture (email requirements)' -ScriptPath $checkPrereqsScript -Arguments @{ Config = $failEmailConfig } -ExpectedExitCode 1 -ExpectedOutput 'email.smtpHost is empty'

  $defaultSmokeArgs = @{}
  if (-not [string]::IsNullOrWhiteSpace($AhkExe)) {
    $defaultSmokeArgs['AhkExe'] = $AhkExe
  }

  Invoke-PowerShellStep -Name 'Dry-run smoke path (literal no-arg default)' -ScriptPath $smokeScript -Arguments $defaultSmokeArgs -ExpectedOutput @(
    "Using repo-local readiness fixture: $passConfig",
    'Smoke test OK.'
  )

  if (($SmokeConfig -replace '/', '\') -ine ($passConfig -replace '/', '\')) {
    $smokeArgs = @{ Config = $SmokeConfig }
    if (-not [string]::IsNullOrWhiteSpace($AhkExe)) {
      $smokeArgs['AhkExe'] = $AhkExe
    }

    Invoke-PowerShellStep -Name 'Dry-run smoke path (explicit config override)' -ScriptPath $smokeScript -Arguments $smokeArgs -ExpectedOutput 'Smoke test OK.'
  }

  Write-Host 'Regression suite OK.'
}
finally {
  if ($null -eq $originalZipPass) {
    Remove-Item Env:READINESS_ZIP_PASS -ErrorAction SilentlyContinue
  }
  else {
    $env:READINESS_ZIP_PASS = $originalZipPass
  }

  if ($null -eq $originalSmtpPass) {
    Remove-Item Env:READINESS_SMTP_PASS -ErrorAction SilentlyContinue
  }
  else {
    $env:READINESS_SMTP_PASS = $originalSmtpPass
  }
}
