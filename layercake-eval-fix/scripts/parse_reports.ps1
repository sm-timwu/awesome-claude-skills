param(
  [string]$ReportsPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake\evals\reports',
  [switch]$AsJson
)

function Get-ReportResults {
  param([string]$ReportPath)

  $lines = Get-Content -Path $ReportPath
  $results = @()
  $current = $null
  $inMetrics = $false

  foreach ($line in $lines) {
    if ($line -match '^Test Case #(\d+)') {
      if ($null -ne $current) {
        $current.FailCount = $current.FailedMetrics.Count
        $results += [pscustomobject]$current
      }

      $current = [ordered]@{
        ReportPath = $ReportPath
        TestCase = [int]$matches[1]
        SessionId = ''
        FailedMetrics = @()
        FailCount = 0
      }
      $inMetrics = $false
      continue
    }

    if ($null -ne $current -and $line -match '^Session ID:\s*(\S+)') {
      $current.SessionId = $matches[1]
      continue
    }

    if ($line -match '^Metrics Summary:') {
      $inMetrics = $true
      continue
    }

    if ($inMetrics) {
      if ($line -match '^\s*-\s*(.+?)\s*\(score:\s*([0-9.]+),\s*threshold:\s*([0-9.]+)\)') {
        $metricRaw = $matches[1]
        $metricName = $metricRaw -replace '^[^A-Za-z0-9]+', ''
        $metricName = $metricName -replace '^.*?\.\s*', ''

        $score = [double]$matches[2]
        $threshold = [double]$matches[3]

        if ($score -lt $threshold) {
          $current.FailedMetrics += $metricName
        }
      }

      if ($line -match '^---' -or $line -match '^\s*$') {
        $inMetrics = $false
      }
    }
  }

  if ($null -ne $current) {
    $current.FailCount = $current.FailedMetrics.Count
    $results += [pscustomobject]$current
  }

  return $results
}

if (-not (Test-Path $ReportsPath)) {
  throw "Reports folder not found: $ReportsPath"
}

$all = @()
$reportFiles = Get-ChildItem -Path $ReportsPath -File -Filter '*.txt'

foreach ($report in $reportFiles) {
  $all += Get-ReportResults -ReportPath $report.FullName
}

if ($AsJson) {
  $all | ConvertTo-Json -Depth 6
} else {
  $all
}
