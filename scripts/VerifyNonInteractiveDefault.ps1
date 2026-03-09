$ErrorActionPreference = 'Stop'

$base = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $base 'src\OneClickBackup.ahk'
if (-not (Test-Path $scriptPath)) {
  Write-Error "AHK script not found: $scriptPath"
  exit 1
}

$content = Get-Content $scriptPath -Raw
$errors = @()

if ($content -notmatch 'opts := \{ configPath: "", dryRun: false, interactive: false \}') {
  $errors += 'ParseArgs no longer defaults interactive to false.'
}

if ($content -notmatch 'if \(arg = "--interactive"\) \{\s*opts\.interactive := true') {
  $errors += 'ParseArgs no longer enables interactive mode only via --interactive.'
}

if ($content -notmatch 'MaybeShowDialog\(interactive, text\) \{\s*if \(interactive\)\s*MsgBox text\s*\}') {
  $errors += 'MaybeShowDialog no longer gates MsgBox behind the interactive flag.'
}

$msgBoxCount = [regex]::Matches($content, '\bMsgBox\b').Count
if ($msgBoxCount -ne 1) {
  $errors += "Expected exactly 1 MsgBox call, found $msgBoxCount."
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Verified: unattended runs remain non-interactive by default.'
