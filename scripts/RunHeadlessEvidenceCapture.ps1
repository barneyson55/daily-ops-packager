param(
  [ValidateSet('Safe', 'Pass')]
  [string]$Mode = 'Safe',
  [string]$Config = 'config\app.ini',
  [string]$Output = 'docs\headless_default_release_gate.md',
  [string]$Transcript = '',
  [string]$AhkExe = '',
  [string]$ScheduledTaskName = '',
  [string]$ObservedBy = ''
)

$scriptPath = Join-Path $PSScriptRoot 'CaptureHeadlessEvidence.ps1'
if (-not (Test-Path $scriptPath)) {
  Write-Error "CaptureHeadlessEvidence.ps1 not found: $scriptPath"
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
    if (-not [string]::IsNullOrWhiteSpace($ObservedBy)) {
      Write-Warning 'Ignoring -ObservedBy in Safe mode. Use -Mode Pass once you have directly observed the Windows run stay headless.'
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
    $invokeArgs['ObservedScheduledTaskHeadless'] = $true
    $invokeArgs['ObservedBy'] = $ObservedBy
  }
}

& $scriptPath @invokeArgs
