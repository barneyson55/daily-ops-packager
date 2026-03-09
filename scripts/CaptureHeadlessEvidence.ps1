param(
  [string]$Config = "config\app.ini",
  [string]$Output = "docs\headless_default_release_gate.md",
  [string]$Transcript = "",
  [string]$AhkExe = "",
  [string]$ScheduledTaskName = "",
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
$backupLogPath = Join-Path $base ("logs\backup_{0}.log" -f (Get-Date -Format yyyyMMdd))

if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
  Write-Error ("This script must be run from native Windows PowerShell in C:\CORE\daily-ops-packager. Required action: open Windows PowerShell in the repo root and rerun `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini`. Current platform: {0}" -f [System.Environment]::OSVersion.Platform)
  exit 2
}

$transcriptPath = if ($Transcript) {
  if ([System.IO.Path]::IsPathRooted($Transcript)) {
    $Transcript
  } else {
    Join-Path $base $Transcript
  }
} else {
  Join-Path $base ("logs\headless_release_gate_{0}.log" -f (Get-Date -Format yyyyMMddTHHmmss))
}

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

$transcriptDir = Split-Path -Parent $transcriptPath
if ($transcriptDir -and -not (Test-Path $transcriptDir)) {
  New-Item -ItemType Directory -Path $transcriptDir -Force | Out-Null
}

$transcriptStarted = $false
try {
  Start-Transcript -Path $transcriptPath -Force | Out-Null
  $transcriptStarted = $true
} catch {
  Write-Warning ("Transcript capture could not be started: {0}" -f $_.Exception.Message)
}

$resolvedAhkExe = Resolve-AhkExe $AhkExe

$results = @()
$results += Invoke-CapturedStep -Name "Runtime context" -Command 'built-in capture (computer/user/os/paths)' -ScriptBlock {
  @(
    "ComputerName: $env:COMPUTERNAME",
    "UserName: $env:USERNAME",
    "CurrentDirectory: $(Get-Location)",
    "PowerShellVersion: $($PSVersionTable.PSVersion.ToString())",
    "OSVersion: $([System.Environment]::OSVersion.VersionString)",
    "ConfigPath: $configPath",
    "TranscriptPath: $transcriptPath",
    "AhkExe: $(if ($resolvedAhkExe) { $resolvedAhkExe } else { '(not resolved yet)' })",
    "SummaryPath: $summaryPath",
    "BackupLogPath: $backupLogPath"
  )
}
$results += Invoke-CapturedStep -Name "Static headless-default guard" -Command 'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1' -ScriptBlock {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript
}
$results += Invoke-CapturedStep -Name "Dry-run smoke test" -Command ("powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config {0}" -f $Config) -ScriptBlock {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $smokeScript -Config $Config
}

$realRunResult = $null
if ($IncludeRealRun) {
  if (-not $resolvedAhkExe) {
    Write-Error 'AutoHotkey not found in PATH. Pass -AhkExe C:\Path\To\AutoHotkey64.exe'
    if ($transcriptStarted) {
      Stop-Transcript | Out-Null
    }
    exit 1
  }

  $realRunResult = Invoke-CapturedStep -Name "Default real run" -Command ("{0} src\\OneClickBackup.ahk --config {1}" -f $resolvedAhkExe, $Config) -ScriptBlock {
    & $resolvedAhkExe $ahkScript --config $Config
  }
  $results += $realRunResult
}

$scheduledTaskResult = $null
if ($ScheduledTaskName) {
  $scheduledTaskResult = Invoke-CapturedStep -Name "Scheduled task status" -Command ("schtasks /Query /TN \"{0}\" /V /FO LIST" -f $ScheduledTaskName) -ScriptBlock {
    & schtasks /Query /TN $ScheduledTaskName /V /FO LIST
  }
  $results += $scheduledTaskResult
}

$summaryTail = Invoke-CapturedStep -Name "Summary tail" -Command 'powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"' -ScriptBlock {
  if (-not (Test-Path $summaryPath)) {
    throw "Summary file not found: $summaryPath"
  }
  Get-Content $summaryPath -Tail 1
}
$results += $summaryTail

$backupLogTail = Invoke-CapturedStep -Name "Backup log tail" -Command 'powershell -NoProfile -Command "Get-Content logs\backup_$(Get-Date -Format yyyyMMdd).log -Tail 20"' -ScriptBlock {
  if (-not (Test-Path $backupLogPath)) {
    throw "Backup log not found: $backupLogPath"
  }
  Get-Content $backupLogPath -Tail 20
}
$results += $backupLogTail

$failedSteps = @($results | Where-Object { $_.ExitCode -ne 0 })
$allStepsPassed = ($failedSteps.Count -eq 0)
$realRunCaptured = [bool]$IncludeRealRun
$scheduledTaskEvidenceCaptured = [bool]$ScheduledTaskName
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
  'PENDING_SCHEDULED_OBSERVATION' { 'Trigger the scheduled/manual default path on Windows and rerun this script with -ObservedScheduledTaskHeadless (and optionally -ScheduledTaskName) once confirmed headless.' }
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
$lines += ('- Transcript: `{0}`' -f $transcriptPath)
$lines += ('- Real run captured: **{0}**' -f ($(if ($realRunCaptured) { 'yes' } else { 'no' })))
$lines += ('- Scheduled task query captured: **{0}**' -f ($(if ($scheduledTaskEvidenceCaptured) { 'yes' } else { 'no' })))
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
Write-Host "Transcript: $transcriptPath"
Write-Host "Status: $status"

if ($transcriptStarted) {
  Stop-Transcript | Out-Null
}
