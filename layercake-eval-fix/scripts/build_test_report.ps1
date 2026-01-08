param(
  [string]$RepoPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake',
  [string]$ReportsPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake\evals\reports',
  [string]$DebugPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake\evals\debug',
  [string]$OutputPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake\evals\test_report.txt'
)

function Convert-ToAscii {
  param([string]$Text)
  return ([regex]::Replace($Text, '[^\x00-\x7F]', '?'))
}

function Get-TranscriptEvidence {
  param(
    [string]$TranscriptPath,
    [string]$MetricName
  )

  if (-not (Test-Path $TranscriptPath)) {
    return "Transcript not found: $TranscriptPath"
  }

  $lines = Get-Content -Path $TranscriptPath
  $matchIndex = -1

  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match [regex]::Escape($MetricName)) {
      $matchIndex = $i
      break
    }
  }

  if ($matchIndex -ge 0) {
    $start = [Math]::Max(0, $matchIndex - 2)
    $end = [Math]::Min($lines.Count - 1, $matchIndex + 2)
    $slice = $lines[$start..$end] -join "`n"
    return Convert-ToAscii $slice
  }

  $fallback = $lines | Select-Object -First 20
  return Convert-ToAscii ($fallback -join "`n")
}

$parseScript = Join-Path $PSScriptRoot 'parse_reports.ps1'
if (-not (Test-Path $parseScript)) {
  throw "parse_reports.ps1 not found: $parseScript"
}

if (-not (Test-Path $ReportsPath)) {
  throw "Reports folder not found: $ReportsPath"
}

if (-not (Test-Path $DebugPath)) {
  throw "Debug folder not found: $DebugPath"
}

$rawJson = & $parseScript -ReportsPath $ReportsPath -AsJson
$results = @()
if ($rawJson) {
  $results = $rawJson | ConvertFrom-Json
}

$failing = $results | Where-Object { $_.FailCount -gt 0 }

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$reportLines = @()
$reportLines += "Layercake Eval Test Report"
$reportLines += "Generated: $timestamp"
$reportLines += "Total failing test cases: $($failing.Count)"
$reportLines += ''

if (-not $failing -or $failing.Count -eq 0) {
  $reportLines += 'No failures found.'
  $reportLines | Set-Content -Path $OutputPath -Encoding ascii
  Write-Output 0
  return
}

$issues = @{}
foreach ($case in $failing) {
  foreach ($metric in $case.FailedMetrics) {
    if (-not $issues.ContainsKey($metric)) {
      $issues[$metric] = @()
    }
    $issues[$metric] += $case
  }
}

$issueIndex = 1
foreach ($metricName in $issues.Keys) {
  $reportLines += "Issue ${issueIndex}: $metricName"
  $reportLines += '-' * 60

  foreach ($case in $issues[$metricName]) {
    $sessionId = $case.SessionId
    $transcriptName = "eval_transcript_$sessionId.txt"
    $transcriptPath = Join-Path $DebugPath $transcriptName

    $reportLines += "Report: $($case.ReportPath)"
    $reportLines += "Test Case: #$($case.TestCase)"
    $reportLines += "Session ID: $sessionId"
    $reportLines += "Transcript: $transcriptPath"
    $reportLines += "Evidence:"
    $reportLines += Get-TranscriptEvidence -TranscriptPath $transcriptPath -MetricName $metricName
    $reportLines += ''
  }

  $reportLines += ''
  $issueIndex++
}

$reportLines | Set-Content -Path $OutputPath -Encoding ascii
Write-Output $failing.Count
