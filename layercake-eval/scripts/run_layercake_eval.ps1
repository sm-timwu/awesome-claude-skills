param(
  [string]$RepoPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake',
  [string]$ServerSkillScript = 'C:\Users\tim.wu\.codex\skills\layercake-server\scripts\run_layercake.ps1',
  [string]$HealthUrl = 'http://localhost:5001/health',
  [int]$HealthTimeoutSec = 60,
  [int]$HealthPollSec = 2
)

$activatePath = Join-Path $RepoPath 'venv\Scripts\Activate.ps1'
$evalPath = Join-Path $RepoPath 'evals\eval_runner.py'
$reportsPath = Join-Path $RepoPath 'evals\reports'

if (!(Test-Path $RepoPath)) {
  throw "Repo not found: $RepoPath"
}

if (!(Test-Path $activatePath)) {
  throw "Virtualenv activation script not found: $activatePath"
}

if (!(Test-Path $evalPath)) {
  throw "Eval runner not found: $evalPath"
}

if (!(Test-Path $reportsPath)) {
  throw "Reports folder not found: $reportsPath"
}

if (!(Test-Path $ServerSkillScript)) {
  throw "Server helper script not found: $ServerSkillScript"
}

$serverProcess = Start-Process -FilePath 'powershell' -ArgumentList @(
  '-NoProfile',
  '-ExecutionPolicy',
  'Bypass',
  '-File',
  $ServerSkillScript
) -PassThru -WindowStyle Hidden

$deadline = (Get-Date).AddSeconds($HealthTimeoutSec)
$serverReady = $false

while ((Get-Date) -lt $deadline) {
  try {
    $response = Invoke-RestMethod -Method Get -Uri $HealthUrl -TimeoutSec 5
    if ($null -ne $response -and $response.status -eq 'healthy') {
      $serverReady = $true
      break
    }
  } catch {
    # Keep polling until timeout
  }

  if ($serverProcess.HasExited) {
    throw "Server process exited before health check passed."
  }

  Start-Sleep -Seconds $HealthPollSec
}

if (-not $serverReady) {
  throw "Server did not become healthy within $HealthTimeoutSec seconds."
}

$evalStart = Get-Date
$evalCommand = "& { Set-Location '$RepoPath'; . '$activatePath'; python '$evalPath' }"
$evalProcess = Start-Process -FilePath 'powershell' -ArgumentList @(
  '-NoProfile',
  '-ExecutionPolicy',
  'Bypass',
  '-Command',
  $evalCommand
) -PassThru

Wait-Process -Id $evalProcess.Id

$newReports = Get-ChildItem -Path $reportsPath -File | Where-Object { $_.LastWriteTime -ge $evalStart }

if (-not $newReports -or $newReports.Count -eq 0) {
  Write-Output 'No new reports found.'
  return
}

foreach ($report in $newReports) {
  Write-Output "Report: $($report.FullName)"
  Write-Output (Get-Content -Path $report.FullName -Raw)
}
