param(
  [string]$Config = "config\app.ini",
  [string]$Output = "docs\headless_default_release_gate.md",
  [string]$AhkExe = "",
  [switch]$IncludeRealRun,
  [switch]$ObservedDefaultRunHeadless,
  [switch]$ObservedScheduledTaskHeadless
)

$base = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $base $Config
$outputPath = Join-Path $base $Output
$checkScript = Join-Path $PSScriptRoot "CheckHeadlessDefault.ps1"
$smokeScript = Join-Path $PSScriptRoot "SmokeTest.ps1"
$ahkScript = Join-Path $base "src\OneClickBackup.ahk"
$summaryPath = Join-Path $base ("logs\summary_{0}.csv" -f (Get-Date -Format yyyyMMdd))

if (-not (Test-Path $configPath)) {
  Write-Error "Config not found: $configPath"
  exit 1
}
if (-not (Test-Path $checkScript)) {
  Write-Error "CheckHeadlessDefault.ps1 not found: $checkScript"
  exit 1
}
if (-not (Test-Path $smokeScript)) {
  Write-Error "SmokeTest.ps1 not found: $smokeScript"
  exit 1
}
if (-not (Test-Path $ahkScript)) {
  Write-Error "AHK script not found: $ahkScript"
  exit 1
}

function Resolve-AhkExe([string]$Candidate) {
  if ($Candidate) {
    return $Candidate
  }

  $cmd = Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue
  if (-not $cmd) {
    $cmd = Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue
  }
  if ($cmd) {
    return $cmd.Source
  }

  return ""
}

function Invoke-CapturedStep {
  param(
    [string]$Name,
    [string]$Command,
    [scriptblock]$ScriptBlock
  )

  $outputLines = @()
  $exitCode = 0
  $global:LASTEXITCODE = 0

  try {
    $outputLines = & $ScriptBlock 2>&1 | ForEach-Object { $_.ToString() }
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
      $exitCode = 0
    }
  } catch {
    $outputLines += ($_ | Out-String).TrimEnd()
    $exitCode = 1
  }

  [pscustomobject]@{
    Name = $Name
    Command = $Command
    ExitCode = [int]$exitCode
    Output = ($outputLines -join "`n").TrimEnd()
  }
}

function Format-Section {
  param(
    [string]$Title,
    [string]$Body
  )

  if ([string]::IsNullOrWhiteSpace($Body)) {
    $Body = "(no output)"
  }

  @(
    "## $Title",
    "",
    '```text',
    $Body,
    '```',
    ""
  ) -join "`n"
}

$results = @()
$results += Invoke-CapturedStep -Name "Static headless-default guard" -Command 'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1' -ScriptBlock {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript
}
$results += Invoke-CapturedStep -Name "Dry-run smoke test" -Command ("powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config {0}" -f $Config) -ScriptBlock {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $smokeScript -Config $Config
}

$realRunResult = $null
if ($IncludeRealRun) {
  $resolvedAhkExe = Resolve-AhkExe $AhkExe
  if (-not $resolvedAhkExe) {
    Write-Error 'AutoHotkey not found in PATH. Pass -AhkExe C:\Path\To\AutoHotkey64.exe'
    exit 1
  }

  $realRunResult = Invoke-CapturedStep -Name "Default real run" -Command ("{0} src\\OneClickBackup.ahk --config {1}" -f $resolvedAhkExe, $Config) -ScriptBlock {
    & $resolvedAhkExe $ahkScript --config $Config
  }
  $results += $realRunResult
}

$summaryTail = Invoke-CapturedStep -Name "Summary tail" -Command 'powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"' -ScriptBlock {
  if (-not (Test-Path $summaryPath)) {
    throw "Summary file not found: $summaryPath"
  }
  Get-Content $summaryPath -Tail 1
}
$results += $summaryTail

$failedSteps = @($results | Where-Object { $_.ExitCode -ne 0 })
$allStepsPassed = ($failedSteps.Count -eq 0)
$realRunCaptured = [bool]$IncludeRealRun
$defaultObserved = [bool]$ObservedDefaultRunHeadless
$scheduledObserved = [bool]$ObservedScheduledTaskHeadless

$status = if (-not $allStepsPassed) {
  'FAIL'
} elseif (-not $realRunCaptured) {
  'PENDING_REAL_RUN'
} elseif (-not $defaultObserved) {
  'PENDING_DEFAULT_OBSERVATION'
} elseif (-not $scheduledObserved) {
  'PENDING_SCHEDULED_OBSERVATION'
} else {
  'PASS'
}

$nextAction = switch ($status) {
  'FAIL' { 'Fix the failing command(s), then rerun this capture script on Windows.' }
  'PENDING_REAL_RUN' { 'Run this script again with -IncludeRealRun on a real Windows machine after reviewing config safety.' }
  'PENDING_DEFAULT_OBSERVATION' { 'Repeat the default real run and rerun this script with -ObservedDefaultRunHeadless after confirming no modal dialog appeared.' }
  'PENDING_SCHEDULED_OBSERVATION' { 'Trigger the scheduled/manual default path on Windows and rerun this script with -ObservedScheduledTaskHeadless once confirmed headless.' }
  default { 'Headless-default release gate evidence is complete for this capture.' }
}

$outputDir = Split-Path -Parent $outputPath
if ($outputDir -and -not (Test-Path $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$lines = @()
$lines += '# Headless Default Release Gate (Windows evidence)'
$lines += ''
$lines += ('- Generated: {0}' -f ((Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')))
$lines += ('- Status: **{0}**' -f $status)
$lines += ('- Config: `{0}`' -f $Config)
$lines += ('- Real run captured: **{0}**' -f ($(if ($realRunCaptured) { 'yes' } else { 'no' })))
$lines += ('- Manual default-run observation recorded: **{0}**' -f ($(if ($defaultObserved) { 'yes' } else { 'no' })))
$lines += ('- Manual scheduled-task observation recorded: **{0}**' -f ($(if ($scheduledObserved) { 'yes' } else { 'no' })))
$lines += ''
$lines += '## Verification commands'
$lines += ''
foreach ($result in $results) {
  $lines += ('- `{0}`' -f $result.Command)
}
$lines += ''
$lines += '## Command results'
$lines += ''
$lines += '| Step | Exit code |'
$lines += '|---|---:|'
foreach ($result in $results) {
  $lines += ('| {0} | {1} |' -f $result.Name, $result.ExitCode)
}
$lines += ''
foreach ($result in $results) {
  $lines += (Format-Section -Title $result.Name -Body $result.Output)
}
$lines += '## Human observation checklist'
$lines += ''
$lines += ('- [{0}] Default run stayed headless (no `MsgBox` / blocking dialog without `--interactive`).' -f ($(if ($defaultObserved) { 'x' } else { ' ' })))
$lines += ('- [{0}] Scheduled/manual default path stayed headless (no `MsgBox` / blocking dialog without `--interactive`).' -f ($(if ($scheduledObserved) { 'x' } else { ' ' })))
$lines += ''
$lines += '## Next action'
$lines += ''
$lines += ('- {0}' -f $nextAction)
$lines += ''

$markdown = ($lines -join "`n").TrimEnd() + "`n"
Set-Content -Path $outputPath -Value $markdown -Encoding UTF8

Write-Host "Wrote headless evidence doc: $outputPath"
Write-Host "Status: $status"
