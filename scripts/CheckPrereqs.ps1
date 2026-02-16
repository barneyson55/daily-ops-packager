param(
  [string]$Config = "config\\app.sample.ini"
)

$base = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $base $Config
if (-not (Test-Path $configPath)) {
  Write-Error "Config not found: $configPath"
  exit 1
}

$values = @{}
$current = ""
foreach ($line in Get-Content $configPath) {
  $l = $line.Trim()
  if ($l -match '^\[(.+)\]$') {
    $current = $Matches[1]
    continue
  }
  if ($l -match '^(.*?)=(.*)$') {
    $key = $Matches[1].Trim()
    $val = $Matches[2].Trim()
    if ($current -ne "") {
      $values["$current.$key"] = [Environment]::ExpandEnvironmentVariables($val)
    }
  }
}

$zipExe = $values['zip.exe']
$rcloneExe = $values['rclone.exe']
$zipEnv = $values['zip.passwordEnv']
$smtpEnv = $values['email.passwordEnv']
$emailEnabled = [int]($values['email.enabled'])

$errors = @()
if (-not $zipExe -or -not (Test-Path $zipExe)) { $errors += "7-Zip not found: $zipExe" }
if (-not $rcloneExe -or -not (Test-Path $rcloneExe)) { $errors += "rclone not found: $rcloneExe" }
if (-not $zipEnv -or -not [Environment]::GetEnvironmentVariable($zipEnv)) { $errors += "Missing env var: $zipEnv" }
if ($emailEnabled -eq 1) {
  if (-not $smtpEnv -or -not [Environment]::GetEnvironmentVariable($smtpEnv)) { $errors += "Missing env var: $smtpEnv" }
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host "All prerequisites look OK."
