param(
  [string]$Config = "config\fixtures\readiness.pass.ini",
  [string]$Output = "docs\headless_default_release_gate.md",
  [string]$Transcript = "",
  [string]$AhkExe = "",
  [string]$ScheduledTaskName = "",
  [string]$ObservedBy = "",
  [switch]$IncludeRealRun,
  [switch]$ConfirmSafeRealRun,
  [switch]$ObservedDefaultRunHeadless,
  [switch]$ObservedScheduledTaskHeadless
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

function New-WrapperCommand {
  param(
    [ValidateSet('Safe', 'Pass')]
    [string]$Mode = 'Safe',
    [string]$ConfigPath = 'config\fixtures\readiness.pass.ini',
    [string]$OutputPath = 'docs\headless_default_release_gate.md',
    [string]$TranscriptPath = '',
    [string]$AhkExePath = '',
    [string]$ScheduledTask = '',
    [string]$ObservedByName = ''
  )

  $parts = @(
    'powershell',
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    'scripts\RunHeadlessEvidenceCapture.ps1'
  )

  if ($Mode -ne 'Safe') {
    $parts += @('-Mode', $Mode)
  }
  if ($ConfigPath -ne 'config\fixtures\readiness.pass.ini') {
    $parts += @('-Config', $ConfigPath)
  }
  if ($OutputPath -ne 'docs\headless_default_release_gate.md') {
    $parts += @('-Output', $OutputPath)
  }
  if (-not [string]::IsNullOrWhiteSpace($TranscriptPath)) {
    $parts += @('-Transcript', $TranscriptPath)
  }
  if (-not [string]::IsNullOrWhiteSpace($AhkExePath)) {
    $parts += @('-AhkExe', $AhkExePath)
  }
  if (-not [string]::IsNullOrWhiteSpace($ScheduledTask)) {
    $parts += @('-ScheduledTaskName', $ScheduledTask)
  }
  if (-not [string]::IsNullOrWhiteSpace($ObservedByName)) {
    $parts += @('-ObservedBy', $ObservedByName)
  }

  return (($parts | ForEach-Object { Format-PowerShellCliToken $_ }) -join ' ')
}

$base = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $base $Config
$outputPath = Join-Path $base $Output
$checkScript = Join-Path $PSScriptRoot "CheckHeadlessDefault.ps1"
$smokeScript = Join-Path $PSScriptRoot "SmokeTest.ps1"
$ahkScript = Join-Path $base "src\OneClickBackup.ahk"
$summaryPath = Join-Path $base ("logs\summary_{0}.csv" -f (Get-Date -Format yyyyMMdd))
$backupLogPath = Join-Path $base ("logs\backup_{0}.log" -f (Get-Date -Format yyyyMMdd))
$defaultFixtureConfig = 'config\fixtures\readiness.pass.ini'
$usingDefaultFixtureConfig = ($Config -replace '/', '\') -ieq $defaultFixtureConfig
$schedulerProofTaskName = if ([string]::IsNullOrWhiteSpace($ScheduledTaskName)) { 'OneClickBackupDaily' } else { $ScheduledTaskName }
$wrapperSafeCaptureCommand = New-WrapperCommand -Mode Safe -ConfigPath $Config -OutputPath $Output -TranscriptPath $Transcript -AhkExePath $AhkExe
$wrapperSafeScheduledCaptureCommand = New-WrapperCommand -Mode Safe -ConfigPath $Config -OutputPath $Output -TranscriptPath $Transcript -AhkExePath $AhkExe -ScheduledTask $schedulerProofTaskName
$wrapperPassCaptureCommand = New-WrapperCommand -Mode Pass -ConfigPath $Config -OutputPath $Output -TranscriptPath $Transcript -AhkExePath $AhkExe -ObservedByName 'YOUR_NAME'
$wrapperScheduledPassCaptureCommand = New-WrapperCommand -Mode Pass -ConfigPath $Config -OutputPath $Output -TranscriptPath $Transcript -AhkExePath $AhkExe -ScheduledTask $schedulerProofTaskName -ObservedByName 'YOUR_NAME'
$assertGateCommand = ('powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path {0}' -f (Format-PowerShellCliToken $Output))

if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
  $windowsRepoRoot = 'C:\CORE\daily-ops-packager'
  Write-Error ((@(
    "This script must be run from native Windows PowerShell in $windowsRepoRoot.",
    'Required human action:',
    "1) Open Windows PowerShell in $windowsRepoRoot",
    "2) Safe first pass: $wrapperSafeCaptureCommand",
    "3) Optional safe scheduler proof: $wrapperSafeScheduledCaptureCommand",
    ("4) If you want live/local evidence instead of the repo fixture, rerun with -Config config\\app.ini and review that config before any real backup."),
    ("5) Review {0} and only continue if a real backup is safe for the configured upload/email target." -f $Config),
    "6) PASS-grade capture after direct observation: $wrapperPassCaptureCommand",
    "7) Optional PASS-grade scheduler proof: $wrapperScheduledPassCaptureCommand",
    ("Current platform: {0}" -f [System.Environment]::OSVersion.Platform)
  ) -join "`n"))
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
if ($IncludeRealRun -and -not $ConfirmSafeRealRun) {
  Write-Error (("Refusing to perform the real backup run without explicit acknowledgement. Review {0} and rerun with -IncludeRealRun -ConfirmSafeRealRun only when the configured upload/email target is safe." -f $Config))
  exit 1
}
if (($ObservedDefaultRunHeadless -or $ObservedScheduledTaskHeadless) -and [string]::IsNullOrWhiteSpace($ObservedBy)) {
  Write-Error 'Observation flags require -ObservedBy "name-or-handle" so the evidence artifact records who confirmed the headless behavior.'
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

function Get-IniValues([string]$Path) {
  $values = @{}
  $current = ""

  foreach ($line in Get-Content $Path) {
    $trimmed = $line.Trim()
    if ($trimmed -match '^\[(.+)\]$') {
      $current = $Matches[1]
      continue
    }
    if ($trimmed -match '^(.*?)=(.*)$') {
      $key = $Matches[1].Trim()
      $value = [Environment]::ExpandEnvironmentVariables($Matches[2].Trim())
      if ($current -ne "") {
        $fullKey = "$current.$key"
        if ($value -and $fullKey -in @('paths.watchDir', 'paths.outDir', 'paths.tmpDir', 'zip.exe', 'rclone.exe')) {
          $isAbsolute = ($value -match '^[A-Za-z]:\\') -or $value.StartsWith('\\')
          if (-not $isAbsolute) {
            $value = Join-Path $base $value
          }
        }
        $values[$fullKey] = $value
      }
    }
  }

  return $values
}

function Show-ConfigValue([string]$Value, [string]$Fallback = '(unset)') {
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $Fallback
  }

  return $Value
}

function Mask-EmailAddress([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return '(unset)'
  }

  if ($Value -notmatch '^(?<local>[^@]+)@(?<domain>.+)$') {
    return $Value
  }

  $local = $Matches['local']
  $domain = $Matches['domain']
  $visible = if ($local.Length -gt 1) { $local.Substring(0, 1) + '***' } else { '***' }
  return "$visible@$domain"
}

function Test-PlaceholderValue([string]$Value) {
  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $false
  }

  return ($Value -match 'example\.com|example\\|^myremote:|sample|placeholder')
}

function Get-XmlNodeInnerText {
  param(
    [System.Xml.XmlNode]$Node,
    [string]$XPath
  )

  $valueNode = $Node.SelectSingleNode($XPath)
  if ($null -eq $valueNode -or [string]::IsNullOrWhiteSpace($valueNode.InnerText)) {
    return ""
  }

  return $valueNode.InnerText.Trim()
}

function Get-ScheduledTaskActionAuditLines {
  param(
    [string]$TaskName,
    [string]$RepoRoot
  )

  $xmlOutput = & schtasks /Query /TN $TaskName /XML ONE 2>&1 | ForEach-Object { $_.ToString() }
  $xmlExitCode = $LASTEXITCODE
  if ($xmlExitCode -ne 0) {
    throw "schtasks /Query /XML failed with exit code $xmlExitCode"
  }

  [xml]$taskXml = ($xmlOutput -join "`n")
  $execNode = $taskXml.SelectSingleNode('/*[local-name()="Task"]/*[local-name()="Actions"]/*[local-name()="Exec"]')
  if ($null -eq $execNode) {
    throw 'Task XML does not contain an Exec action.'
  }

  $command = Get-XmlNodeInnerText -Node $execNode -XPath './*[local-name()="Command"]'
  $arguments = Get-XmlNodeInnerText -Node $execNode -XPath './*[local-name()="Arguments"]'
  $workingDirectory = Get-XmlNodeInnerText -Node $execNode -XPath './*[local-name()="WorkingDirectory"]'

  $usesInteractiveFlag = [bool]($arguments -match '(^|[\s"])--interactive($|[\s"])')
  $targetsMainScript = [bool]($arguments -match 'OneClickBackup\.ahk')
  $hasConfigFlag = [bool]($arguments -match '(^|[\s"])(--config|-c)($|[\s"])')
  $commandLooksLikeAutoHotkey = [bool]($command -match '(?i)AutoHotkey(?:64)?\.exe$')
  $workingDirectoryMatchesRepoRoot = if ([string]::IsNullOrWhiteSpace($workingDirectory)) {
    $false
  } else {
    [string]::Equals(
      [System.IO.Path]::GetFullPath($workingDirectory).TrimEnd('\'),
      [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd('\'),
      [System.StringComparison]::OrdinalIgnoreCase
    )
  }

  $warnings = @()
  if (-not $workingDirectoryMatchesRepoRoot) {
    $warnings += 'WorkingDirectory does not match repo root.'
  }

  if ($usesInteractiveFlag) {
    throw 'Scheduled task arguments include --interactive; scheduled/default execution must stay headless.'
  }
  if (-not $targetsMainScript) {
    throw 'Scheduled task arguments do not target OneClickBackup.ahk.'
  }
  if (-not $hasConfigFlag) {
    throw 'Scheduled task arguments do not include --config/-c.'
  }
  if (-not $commandLooksLikeAutoHotkey) {
    throw 'Scheduled task command does not look like an AutoHotkey executable.'
  }

  return @(
    "Command: $(Show-ConfigValue $command)",
    "Arguments: $(Show-ConfigValue $arguments)",
    "WorkingDirectory: $(Show-ConfigValue $workingDirectory)",
    "UsesInteractiveFlag: $usesInteractiveFlag",
    "TargetsMainScript: $targetsMainScript",
    "HasConfigFlag: $hasConfigFlag",
    "CommandLooksLikeAutoHotkey: $commandLooksLikeAutoHotkey",
    "WorkingDirectoryMatchesRepoRoot: $workingDirectoryMatchesRepoRoot",
    "Warnings: $(if ($warnings.Count -gt 0) { $warnings -join '; ' } else { '(none)' })"
  )
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
$configValues = Get-IniValues $configPath

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
$results += Invoke-CapturedStep -Name "Real-run safety review" -Command 'built-in capture (resolved config targets and env readiness)' -ScriptBlock {
  $watchDir = $configValues['paths.watchDir']
  $outDir = $configValues['paths.outDir']
  $tmpDir = $configValues['paths.tmpDir']
  $zipExe = $configValues['zip.exe']
  $zipPasswordEnv = $configValues['zip.passwordEnv']
  $rcloneExe = $configValues['rclone.exe']
  $rcloneRemote = $configValues['rclone.remote']
  $emailEnabled = [int](Show-ConfigValue $configValues['email.enabled'] '0')
  $emailFrom = $configValues['email.from']
  $emailTo = $configValues['email.to']
  $smtpPasswordEnv = $configValues['email.passwordEnv']

  $realRunEffects = @()
  if (-not [string]::IsNullOrWhiteSpace($rcloneRemote)) {
    $realRunEffects += "upload->$rcloneRemote"
  }
  if ($emailEnabled -eq 1) {
    $realRunEffects += ("email->{0}" -f (Mask-EmailAddress $emailTo))
  }
  if ($realRunEffects.Count -eq 0) {
    $realRunEffects += 'local archive only (no remote/email target detected)'
  }

  @(
    "WatchDir: $(Show-ConfigValue $watchDir)",
    "WatchDirExists: $(if ([string]::IsNullOrWhiteSpace($watchDir)) { $false } else { Test-Path $watchDir })",
    "OutDir: $(Show-ConfigValue $outDir)",
    "OutDirExists: $(if ([string]::IsNullOrWhiteSpace($outDir)) { $false } else { Test-Path $outDir })",
    "TmpDir: $(Show-ConfigValue $tmpDir)",
    "TmpDirExists: $(if ([string]::IsNullOrWhiteSpace($tmpDir)) { $false } else { Test-Path $tmpDir })",
    "ZipExe: $(Show-ConfigValue $zipExe)",
    "ZipExeExists: $(if ([string]::IsNullOrWhiteSpace($zipExe)) { $false } else { Test-Path $zipExe })",
    "ZipPasswordEnv: $(Show-ConfigValue $zipPasswordEnv)",
    "ZipPasswordEnvPresent: $(if ([string]::IsNullOrWhiteSpace($zipPasswordEnv)) { $false } else { [bool][Environment]::GetEnvironmentVariable($zipPasswordEnv) })",
    "RcloneExe: $(Show-ConfigValue $rcloneExe)",
    "RcloneExeExists: $(if ([string]::IsNullOrWhiteSpace($rcloneExe)) { $false } else { Test-Path $rcloneExe })",
    "RcloneRemote: $(Show-ConfigValue $rcloneRemote)",
    "RcloneRemoteLooksPlaceholder: $(Test-PlaceholderValue $rcloneRemote)",
    "EmailEnabled: $emailEnabled",
    "EmailFrom: $(Mask-EmailAddress $emailFrom)",
    "EmailTo: $(Mask-EmailAddress $emailTo)",
    "EmailTargetLooksPlaceholder: $([bool]((Test-PlaceholderValue $emailFrom) -or (Test-PlaceholderValue $emailTo)))",
    "SmtpPasswordEnv: $(Show-ConfigValue $smtpPasswordEnv)",
    "SmtpPasswordEnvPresent: $(if ([string]::IsNullOrWhiteSpace($smtpPasswordEnv)) { $false } else { [bool][Environment]::GetEnvironmentVariable($smtpPasswordEnv) })",
    "RealRunEffects: $($realRunEffects -join '; ')"
  )
}
$results += Invoke-CapturedStep -Name "Static headless-default guard" -Command 'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1' -ScriptBlock {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript
}
$smokeTestCommand = if ($usingDefaultFixtureConfig) {
  'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1'
} else {
  "powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config $Config"
}
$results += Invoke-CapturedStep -Name "Dry-run smoke test" -Command $smokeTestCommand -ScriptBlock {
  if ($usingDefaultFixtureConfig) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $smokeScript
  } else {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $smokeScript -Config $Config
  }
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
$scheduledTaskAuditResult = $null
if ($ScheduledTaskName) {
  $scheduledTaskResult = Invoke-CapturedStep -Name "Scheduled task status" -Command ("schtasks /Query /TN \"{0}\" /V /FO LIST" -f $ScheduledTaskName) -ScriptBlock {
    & schtasks /Query /TN $ScheduledTaskName /V /FO LIST
  }
  $results += $scheduledTaskResult

  $scheduledTaskAuditResult = Invoke-CapturedStep -Name "Scheduled task action audit" -Command ("schtasks /Query /TN \"{0}\" /XML ONE" -f $ScheduledTaskName) -ScriptBlock {
    Get-ScheduledTaskActionAuditLines -TaskName $ScheduledTaskName -RepoRoot $base
  }
  $results += $scheduledTaskAuditResult
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
} else {
  'PASS'
}

$nextAction = switch ($status) {
  'FAIL' { ('Fix the failing command(s), then rerun `{0}` from native Windows PowerShell.' -f $wrapperSafeCaptureCommand) }
  'PENDING_REAL_RUN' { ('After reviewing config safety, rerun `{0}` on a real Windows machine.' -f $wrapperPassCaptureCommand) }
  'PENDING_DEFAULT_OBSERVATION' { ('Repeat the default real run and rerun `{0}` after confirming no modal dialog appeared.' -f $wrapperPassCaptureCommand) }
  default { ('Headless-default release gate evidence is complete for this capture. Verify it with `{0}`.' -f $assertGateCommand) }
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
$lines += ('- Observed by: **{0}**' -f $(if ([string]::IsNullOrWhiteSpace($ObservedBy)) { '(not recorded)' } else { $ObservedBy }))
$lines += ('- Real run captured: **{0}**' -f ($(if ($realRunCaptured) { 'yes' } else { 'no' })))
$lines += ('- Scheduled task query captured: **{0}**' -f ($(if ($scheduledTaskEvidenceCaptured) { 'yes' } else { 'no' })))
$lines += ('- Manual default-run observation recorded: **{0}**' -f ($(if ($defaultObserved) { 'yes' } else { 'no' })))
$lines += ('- Optional scheduled-task human observation recorded: **{0}**' -f ($(if ($scheduledObserved) { 'yes' } else { 'no' })))
$lines += ''
$lines += '## Native Windows operator shortcuts'
$lines += ''
$lines += ('- Safe first pass: `{0}`' -f $wrapperSafeCaptureCommand)
$lines += ('- Safe first pass with scheduler proof: `{0}`' -f $wrapperSafeScheduledCaptureCommand)
$lines += ('- PASS-grade capture after direct observation: `{0}`' -f $wrapperPassCaptureCommand)
$lines += ('- PASS-grade capture with scheduler proof: `{0}`' -f $wrapperScheduledPassCaptureCommand)
$lines += ('- Assert PASS-grade evidence doc: `{0}`' -f $assertGateCommand)
$lines += ''
$lines += '## Verification commands'
$lines += ''
foreach ($result in $results) {
  $lines += ('- `{0}`' -f $result.Command)
}
$lines += ('- `{0}`' -f $assertGateCommand)
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
$lines += ('- Observer: {0}' -f $(if ([string]::IsNullOrWhiteSpace($ObservedBy)) { '(not recorded)' } else { $ObservedBy }))
$lines += ('- [{0}] Default run stayed headless (no `MsgBox` / blocking dialog without `--interactive`).' -f ($(if ($defaultObserved) { 'x' } else { ' ' })))
$lines += ('- [{0}] Optional: a scheduled/manual default path was directly observed staying headless too.' -f ($(if ($scheduledObserved) { 'x' } else { ' ' })))
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
