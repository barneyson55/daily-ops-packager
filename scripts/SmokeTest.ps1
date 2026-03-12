param(
  [string]$Config = "config\fixtures\readiness.pass.ini",
  [string]$AhkExe = ""
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Resolve-AhkExe([string]$Candidate) {
  if (-not [string]::IsNullOrWhiteSpace($Candidate)) {
    return $Candidate
  }

  $cmd = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
  if (-not $cmd) {
    $cmd = Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue
  }

  if ($cmd) {
    return $cmd.Source
  }

  return ''
}

function Invoke-AhkCommand {
  param(
    [string]$Executable,
    [string[]]$Arguments
  )

  $previousErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = 'Continue'
    $output = & $Executable @Arguments 2>&1
    $exitCode = $LASTEXITCODE
  }
  finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }

  return [pscustomobject]@{
    Text = ($output | Out-String).Trim()
    ExitCode = $exitCode
  }
}

function Test-AhkOutputHasWrongMajor([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) {
    return $false
  }

  return (
    $Text -match '(?im)This script requires AutoHotkey v2\.0\.' -or
    $Text -match '(?im)Current interpreter:\s*AutoHotkey v1(?:\.|\b)' -or
    $Text -match '(?im)\bAutoHotkey v1(?:\.|\b)'
  )
}

function Assert-AhkV2([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    Write-Error "AutoHotkey executable not found: $Path"
    exit 1
  }

  $fileVersion = (Get-Item -LiteralPath $Path).VersionInfo.FileVersion
  if (-not [string]::IsNullOrWhiteSpace($fileVersion) -and $fileVersion -notmatch '^2\.') {
    Write-Error "Resolved AutoHotkey executable is not v2 (FileVersion=$fileVersion): $Path"
    exit 1
  }

  $probe = Invoke-AhkCommand -Executable $Path -Arguments @('/ErrorStdOut', '/CP65001')
  if (Test-AhkOutputHasWrongMajor -Text $probe.Text) {
    if ($probe.Text) {
      Write-Host $probe.Text
    }

    Write-Error "Resolved AutoHotkey executable reports the wrong major version: $Path"
    exit 1
  }

  $versionMatch = [regex]::Match($probe.Text, '(?im)^\s*(?:AutoHotkey\s+)?v(?<major>\d+)\.')
  if ($versionMatch.Success -and $versionMatch.Groups['major'].Value -ne '2') {
    if ($probe.Text) {
      Write-Host $probe.Text
    }

    Write-Error "Resolved AutoHotkey executable did not report v2 in probe output: $Path"
    exit 1
  }

  Write-Host "Resolved AutoHotkey v2 executable: $Path"
}

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

  $AhkExe = Resolve-AhkExe $AhkExe
  if (-not $AhkExe) {
    Write-Error "AutoHotkey not found in PATH. Pass -AhkExe C:\Path\To\AutoHotkey64.exe"
    exit 1
  }

  Assert-AhkV2 -Path $AhkExe

  $ahkScript = Join-Path $base "src\OneClickBackup.ahk"
  if (-not (Test-Path $ahkScript)) {
    Write-Error "AHK script not found: $ahkScript"
    exit 1
  }

  Write-Host "Running dry-run..."
  $dryRun = Invoke-AhkCommand -Executable $AhkExe -Arguments @('/ErrorStdOut=UTF-8', $ahkScript, '--config', $Config, '--dry-run')
  if ($dryRun.Text) {
    Write-Host $dryRun.Text
  }

  if (Test-AhkOutputHasWrongMajor -Text $dryRun.Text) {
    Write-Error "Dry-run output shows the wrong AutoHotkey major version. Ensure AutoHotkey v2 is installed and resolved: $AhkExe"
    exit 1
  }

  if ($dryRun.ExitCode -ne 0) {
    Write-Error "Dry-run failed with exit code $($dryRun.ExitCode)"
    exit $dryRun.ExitCode
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
