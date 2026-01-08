param(
  [string]$RepoPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake',
  [string]$ReportPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake\evals\test_report.txt'
)

if (-not (Test-Path $RepoPath)) {
  throw "Repo not found: $RepoPath"
}

if (-not (Test-Path $ReportPath)) {
  Write-Output "Report not found yet: $ReportPath"
}

Set-Location $RepoPath
Write-Output "Opened repo: $RepoPath"
Write-Output "Review report: $ReportPath"
$checklistPath = Join-Path $PSScriptRoot '..\references\fix_checklist.md'
if (Test-Path $checklistPath) {
  Write-Output 'Checklist:'
  Get-Content -Path $checklistPath | ForEach-Object { Write-Output $_ }
} else {
  Write-Output "Checklist missing: $checklistPath"
}
Write-Output 'Apply fixes, run tests as needed, then press Enter to continue.'
Read-Host
