param(
  [string]$Path = 'docs\headless_default_release_gate.md',
  [switch]$RequireScheduledTaskQuery,
  [switch]$RequireScheduledTaskObservation,
  [string]$ScheduledTaskName = ''
)

function Format-PowerShellCliToken([string]$Value) {
  if ([string]::IsNullOrEmpty($Value)) {
    return '""'
  }

  if ($Value -notmatch '[\s"]') {
    return $Value
  }

  return '"' + ($Value -replace '"', '`"') + '"'
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$docPath = if ([System.IO.Path]::IsPathRooted($Path)) {
  $Path
} else {
  Join-Path $repoRoot $Path
}

if (-not (Test-Path $docPath)) {
  Write-Error "Headless release gate doc not found: $docPath"
  exit 1
}

$content = Get-Content -Path $docPath -Raw
$failures = New-Object System.Collections.Generic.List[string]

function Get-BoldMetadataValue {
  param(
    [string]$Label,
    [string]$Body
  )

  $pattern = '(?m)^-\s+' + [Regex]::Escape($Label) + ':\s+\*\*(.*?)\*\*\s*$'
  $match = [Regex]::Match($Body, $pattern)
  if (-not $match.Success) {
    return ''
  }

  return $match.Groups[1].Value.Trim()
}

function Get-ShortcutCommand {
  param(
    [string]$Label,
    [string]$Body
  )

  $pattern = '(?m)^-\s+' + [Regex]::Escape($Label) + ':\s+`([^`]+)`\s*$'
  $match = [Regex]::Match($Body, $pattern)
  if (-not $match.Success) {
    return ''
  }

  return $match.Groups[1].Value.Trim()
}

$status = Get-BoldMetadataValue -Label 'Status' -Body $content
if ($status -ne 'PASS') {
  $failures.Add(("Expected Status: **PASS**, found: {0}" -f $(if ([string]::IsNullOrWhiteSpace($status)) { '(missing)' } else { "**$status**" })))
}

$observedBy = Get-BoldMetadataValue -Label 'Observed by' -Body $content
if ([string]::IsNullOrWhiteSpace($observedBy) -or $observedBy -in @('(not recorded)', 'YourName', 'YOUR_NAME')) {
  $failures.Add(("Observed by is not a real operator name: {0}" -f $(if ([string]::IsNullOrWhiteSpace($observedBy)) { '(missing)' } else { "**$observedBy**" })))
}

$realRunCaptured = Get-BoldMetadataValue -Label 'Real run captured' -Body $content
if ($realRunCaptured -ne 'yes') {
  $failures.Add(("Expected Real run captured: **yes**, found: {0}" -f $(if ([string]::IsNullOrWhiteSpace($realRunCaptured)) { '(missing)' } else { "**$realRunCaptured**" })))
}

$defaultObserved = Get-BoldMetadataValue -Label 'Manual default-run observation recorded' -Body $content
if ($defaultObserved -ne 'yes') {
  $failures.Add(("Expected Manual default-run observation recorded: **yes**, found: {0}" -f $(if ([string]::IsNullOrWhiteSpace($defaultObserved)) { '(missing)' } else { "**$defaultObserved**" })))
}

if ($RequireScheduledTaskQuery) {
  $scheduledTaskQuery = Get-BoldMetadataValue -Label 'Scheduled task query captured' -Body $content
  if ($scheduledTaskQuery -ne 'yes') {
    $failures.Add(("Expected Scheduled task query captured: **yes**, found: {0}" -f $(if ([string]::IsNullOrWhiteSpace($scheduledTaskQuery)) { '(missing)' } else { "**$scheduledTaskQuery**" })))
  }
}

if ($RequireScheduledTaskObservation) {
  $scheduledTaskObserved = Get-BoldMetadataValue -Label 'Optional scheduled-task human observation recorded' -Body $content
  if ($scheduledTaskObserved -ne 'yes') {
    $failures.Add(("Expected Optional scheduled-task human observation recorded: **yes**, found: {0}" -f $(if ([string]::IsNullOrWhiteSpace($scheduledTaskObserved)) { '(missing)' } else { "**$scheduledTaskObserved**" })))
  }
}

if ($failures.Count -gt 0) {
  $resolvedScheduledTaskName = if ([string]::IsNullOrWhiteSpace($ScheduledTaskName)) { 'OneClickBackupDaily' } else { $ScheduledTaskName }

  $safeCaptureParts = @(
    'powershell',
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    'scripts\RunHeadlessEvidenceCapture.ps1'
  )
  if ($RequireScheduledTaskQuery -or $RequireScheduledTaskObservation) {
    $safeCaptureParts += @('-ScheduledTaskName', (Format-PowerShellCliToken $resolvedScheduledTaskName))
  }

  $passCaptureParts = @(
    'powershell',
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    'scripts\RunHeadlessEvidenceCapture.ps1',
    '-Mode',
    'Pass',
    '-ObservedBy',
    '"YourName"'
  )
  if ($RequireScheduledTaskQuery -or $RequireScheduledTaskObservation) {
    $passCaptureParts += @('-ScheduledTaskName', (Format-PowerShellCliToken $resolvedScheduledTaskName))
  }
  if ($RequireScheduledTaskObservation) {
    $passCaptureParts += '-ObservedScheduledTaskHeadless'
  }

  $fallbackSafeCaptureCommand = $safeCaptureParts -join ' '
  $fallbackPassCaptureCommand = $passCaptureParts -join ' '
  $fallbackAssertCommand = 'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path {0}' -f (Format-PowerShellCliToken $Path)

  $preferredSafeCaptureCommand = if ($RequireScheduledTaskQuery -or $RequireScheduledTaskObservation) {
    Get-ShortcutCommand -Label 'Safe first pass with scheduler proof' -Body $content
  } else {
    Get-ShortcutCommand -Label 'Safe first pass' -Body $content
  }
  $preferredPassCaptureCommand = if ($RequireScheduledTaskQuery -or $RequireScheduledTaskObservation) {
    Get-ShortcutCommand -Label 'PASS-grade capture with scheduler proof' -Body $content
  } else {
    Get-ShortcutCommand -Label 'PASS-grade capture after direct observation' -Body $content
  }
  $preferredAssertCommand = Get-ShortcutCommand -Label 'Assert PASS-grade evidence doc' -Body $content

  $requiredCaptureCommand = if ($status -eq 'FAIL') {
    if ([string]::IsNullOrWhiteSpace($preferredSafeCaptureCommand)) { $fallbackSafeCaptureCommand } else { $preferredSafeCaptureCommand }
  } else {
    if ([string]::IsNullOrWhiteSpace($preferredPassCaptureCommand)) { $fallbackPassCaptureCommand } else { $preferredPassCaptureCommand }
  }
  $requiredAssertCommand = if ([string]::IsNullOrWhiteSpace($preferredAssertCommand)) { $fallbackAssertCommand } else { $preferredAssertCommand }

  Write-Error ((@(
    "Headless release gate is not closed: $docPath",
    'Failures:',
    ($failures | ForEach-Object { "- $_" }),
    'Required human action:',
    ('1) Open native Windows PowerShell in C:\CORE\daily-ops-packager'),
    ('2) Capture the missing PASS-grade evidence: {0}' -f $requiredCaptureCommand),
    ('3) Re-run the assert: {0}' -f $requiredAssertCommand)
  ) -join "`n"))
  exit 1
}

Write-Host "Headless release gate PASS is verified: $docPath"
exit 0
