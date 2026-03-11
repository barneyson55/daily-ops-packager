param(
  [string]$Config = "config\\app.sample.ini"
)

$ErrorActionPreference = 'Stop'

function Get-IniData {
  param([string]$Path)

  $data = [ordered]@{}
  $currentSection = ''

  foreach ($line in Get-Content -LiteralPath $Path) {
    $trimmed = $line.Trim()
    if (-not $trimmed -or $trimmed.StartsWith(';') -or $trimmed.StartsWith('#')) {
      continue
    }

    if ($trimmed -match '^\[(.+)\]$') {
      $currentSection = $Matches[1].Trim()
      if (-not $data.Contains($currentSection)) {
        $data[$currentSection] = [ordered]@{}
      }
      continue
    }

    if ($trimmed -match '^(.*?)=(.*)$' -and $currentSection) {
      $key = $Matches[1].Trim()
      $value = [Environment]::ExpandEnvironmentVariables($Matches[2].Trim())
      $data[$currentSection][$key] = $value
    }
  }

  return $data
}

function Get-NestedValue {
  param(
    $Data,
    [string]$Path
  )

  $current = $Data
  foreach ($part in ($Path -split '\.')) {
    if ($current -is [System.Collections.IDictionary] -and $current.Contains($part)) {
      $current = $current[$part]
      continue
    }
    return ''
  }

  return $current
}

function Set-NestedValue {
  param(
    $Data,
    [string]$Path,
    $Value
  )

  $parts = $Path -split '\.'
  $current = $Data
  for ($i = 0; $i -lt ($parts.Length - 1); $i++) {
    $part = $parts[$i]
    if (-not $current.Contains($part)) {
      $current[$part] = [ordered]@{}
    }
    $current = $current[$part]
  }

  $current[$parts[-1]] = $Value
}

function Resolve-ConfigPath {
  param(
    [string]$Value,
    [string]$BaseDir
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $Value
  }

  if ($Value -match '^[A-Za-z]:\\' -or $Value -match '^\\\\' -or $Value -match '^/') {
    return $Value
  }

  return Join-Path $BaseDir $Value
}

function Get-RuleList {
  param(
    $ContractData,
    [string]$Section
  )

  if (-not ($ContractData -is [System.Collections.IDictionary]) -or -not $ContractData.Contains($Section)) {
    return @()
  }

  return @(
    foreach ($name in ($ContractData[$Section].Keys | Sort-Object { [int]$_ })) {
      $ContractData[$Section][$name]
    }
  )
}

function Format-RuleMessage {
  param(
    [string]$Message,
    [string]$KeyPath,
    [string]$Value
  )

  return $Message.Replace('{key}', $KeyPath).Replace('{value}', $Value)
}

function Test-IsTruthy {
  param($Value)

  $text = ([string]$Value).Trim()
  return (-not [string]::IsNullOrWhiteSpace($text)) -and $text -ne '0'
}

function Test-RuleFailure {
  param(
    [string]$Kind,
    [string]$Value
  )

  switch ($Kind) {
    'required-value' {
      return [string]::IsNullOrWhiteSpace($Value)
    }
    'required-dir' {
      if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
      }
      return -not (Test-Path -LiteralPath $Value -PathType Container)
    }
    'required-file' {
      if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
      }
      return -not (Test-Path -LiteralPath $Value -PathType Leaf)
    }
    'required-env' {
      if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
      }
      return [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($Value))
    }
    default {
      throw "Unknown readiness rule type: $Kind"
    }
  }
}

function Invoke-ReadinessSection {
  param(
    $ConfigData,
    $ContractData,
    [string]$Section
  )

  $errors = @()
  foreach ($rule in (Get-RuleList -ContractData $ContractData -Section $Section)) {
    $parts = $rule -split '\|', 3
    if ($parts.Length -lt 3) {
      throw "Invalid readiness rule: $rule"
    }

    $keyPath = $parts[0].Trim()
    $kind = $parts[1].Trim()
    $message = $parts[2].Trim()
    $value = [string](Get-NestedValue -Data $ConfigData -Path $keyPath)

    if (Test-RuleFailure -Kind $kind -Value $value) {
      $errors += (Format-RuleMessage -Message $message -KeyPath $keyPath -Value $value)
    }
  }

  return $errors
}

$base = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $base $Config
if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
  Write-Error "Config not found: $configPath"
  exit 1
}

$contractPath = Join-Path $base 'config\readiness.contract.ini'
if (-not (Test-Path -LiteralPath $contractPath -PathType Leaf)) {
  Write-Error "Readiness contract not found: $contractPath"
  exit 1
}

$configData = Get-IniData -Path $configPath
foreach ($pathKey in @('paths.watchDir', 'paths.outDir', 'paths.tmpDir', 'zip.exe', 'rclone.exe')) {
  $resolved = Resolve-ConfigPath -Value ([string](Get-NestedValue -Data $configData -Path $pathKey)) -BaseDir $base
  Set-NestedValue -Data $configData -Path $pathKey -Value $resolved
}

$contractData = Get-IniData -Path $contractPath
$errors = @()
$errors += Invoke-ReadinessSection -ConfigData $configData -ContractData $contractData -Section 'always'
$errors += Invoke-ReadinessSection -ConfigData $configData -ContractData $contractData -Section 'full'
if (Test-IsTruthy (Get-NestedValue -Data $configData -Path 'email.enabled')) {
  $errors += Invoke-ReadinessSection -ConfigData $configData -ContractData $contractData -Section 'email'
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'All prerequisites look OK.'
