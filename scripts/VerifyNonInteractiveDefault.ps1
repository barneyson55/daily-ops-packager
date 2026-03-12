param(
  [string]$ScriptPath = "src\OneClickBackup.ahk"
)

& (Join-Path $PSScriptRoot 'CheckHeadlessDefault.ps1') -ScriptPath $ScriptPath
