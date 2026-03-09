param(
  [string]$ScriptPath = "src\OneClickBackup.ahk"
)

$base = Split-Path -Parent $PSScriptRoot
$target = Join-Path $base $ScriptPath
if (-not (Test-Path $target)) {
  Write-Error "AHK script not found: $target"
  exit 1
}

$content = Get-Content $target -Raw

$checks = @(
  @{ Name = "interactive defaults false"; Pattern = 'opts := \{ configPath: "", dryRun: false, interactive: false \}' },
  @{ Name = "interactive flag recognized"; Pattern = 'if \(arg = "--interactive"\)' },
  @{ Name = "interactive flag enables dialogs"; Pattern = 'opts\.interactive := true' },
  @{ Name = "dialogs gated behind MaybeShowDialog"; Pattern = 'MaybeShowDialog\(interactive, text\)\s*\{\s*if \(interactive\)\s*MsgBox text\s*\}' },
  @{ Name = "dry-run path stays headless unless interactive"; Pattern = 'summary\.status := "dry-run"[\s\S]*?MaybeShowDialog\(opts\.interactive, "Dry-run: ' },
  @{ Name = "no-files path stays headless unless interactive"; Pattern = 'summary\.status := "no-files"[\s\S]*?MaybeShowDialog\(opts\.interactive, "No files matched today\. Nothing to do\."\)' },
  @{ Name = "success path stays headless unless interactive"; Pattern = 'summary\.status := "success"[\s\S]*?MaybeShowDialog\(opts\.interactive, "Backup complete: ' },
  @{ Name = "error path stays headless unless interactive"; Pattern = 'summary\.status := "failed"[\s\S]*?MaybeShowDialog\(opts\.interactive, "Error: ' }
)

$failures = @()
foreach ($check in $checks) {
  if (-not [regex]::IsMatch($content, $check.Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
    $failures += $check.Name
  }
}

$msgBoxCount = ([regex]::Matches($content, '(?m)^\s*MsgBox\s')).Count
if ($msgBoxCount -ne 1) {
  $failures += "expected exactly one MsgBox call (inside MaybeShowDialog), found $msgBoxCount"
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host "Headless default guard OK."
