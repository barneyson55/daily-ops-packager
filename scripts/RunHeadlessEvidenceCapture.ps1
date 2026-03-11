param(
  [ValidateSet('Safe', 'Pass')]
  [string]$Mode = 'Safe',
  [string]$Config = 'config\app.ini',
  [string]$Output = 'docs\headless_default_release_gate.md',
  [string]$Transcript = '',
  [string]$AhkExe = '',
  [string]$ScheduledTaskName = '',
  [string]$ObservedBy = '',
  [switch]$ObservedScheduledTaskHeadless
)

$scriptPath = Join-Path $PSScriptRoot 'CaptureHeadlessEvidence.ps1'
if (-not (Test-Path $scriptPath)) {
  Write-Error "CaptureHeadlessEvidence.ps1 not found: $scriptPath"
  exit 1
}

$assertScriptPath = Join-Path $PSScriptRoot 'AssertHeadlessReleaseGate.ps1'
if ($Mode -eq 'Pass' -and -not (Test-Path $assertScriptPath)) {
  Write-Error "AssertHeadlessReleaseGate.ps1 not found: $assertScriptPath"
  exit 1
}

$invokeArgs = @{
  Config = $Config
  Output = $Output
}

if (-not [string]::IsNullOrWhiteSpace($Transcript)) {
  $invokeArgs['Transcript'] = $Transcript
}
if (-not [string]::IsNullOrWhiteSpace($AhkExe)) {
  $invokeArgs['AhkExe'] = $AhkExe
}
if (-not [string]::IsNullOrWhiteSpace($ScheduledTaskName)) {
  $invokeArgs['ScheduledTaskName'] = $ScheduledTaskName
}

switch ($Mode) {
  'Safe' {
    if ((-not [string]::IsNullOrWhiteSpace($ObservedBy)) -or $ObservedScheduledTaskHeadless) {
      Write-Warning 'Ignoring observation flags in Safe mode. Use -Mode Pass once you have directly observed the Windows run stay headless.'
    }
  }
  'Pass' {
    if ([string]::IsNullOrWhiteSpace($ObservedBy)) {
      Write-Error 'Pass mode requires -ObservedBy "name-or-handle".'
      exit 1
    }

    $invokeArgs['IncludeRealRun'] = $true
    $invokeArgs['ConfirmSafeRealRun'] = $true
    $invokeArgs['ObservedDefaultRunHeadless'] = $true
    if ($ObservedScheduledTaskHeadless) {
      $invokeArgs['ObservedScheduledTaskHeadless'] = $true
    }
    $invokeArgs['ObservedBy'] = $ObservedBy
  }
}

& $scriptPath @invokeArgs

if ($Mode -eq 'Pass') {
  $assertArgs = @{
    Path = $Output
  }

  if (-not [string]::IsNullOrWhiteSpace($ScheduledTaskName)) {
    $assertArgs['RequireScheduledTaskQuery'] = $true
    $assertArgs['ScheduledTaskName'] = $ScheduledTaskName
  }
  if ($ObservedScheduledTaskHeadless) {
    $assertArgs['RequireScheduledTaskObservation'] = $true
  }

  Write-Host 'Verifying PASS-grade headless release gate evidence...'
  & $assertScriptPath @assertArgs
}
