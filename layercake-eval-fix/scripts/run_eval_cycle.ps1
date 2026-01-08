param(
  [int]$MaxCycles = 3,
  [string]$RepoPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake',
  [string]$EvalScript = 'C:\Users\tim.wu\.codex\skills\layercake-eval\scripts\run_layercake_eval.ps1'
)

$buildScript = Join-Path $PSScriptRoot 'build_test_report.ps1'
if (-not (Test-Path $buildScript)) {
  throw "build_test_report.ps1 not found: $buildScript"
}

if (-not (Test-Path $EvalScript)) {
  throw "Eval script not found: $EvalScript"
}

for ($cycle = 1; $cycle -le $MaxCycles; $cycle++) {
  Write-Output "Cycle $cycle of $MaxCycles"

  $evalProcess = Start-Process -FilePath powershell -ArgumentList @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', $EvalScript
  ) -PassThru -WindowStyle Normal

  Wait-Process -Id $evalProcess.Id

  $failCount = & $buildScript -RepoPath $RepoPath

  if ($failCount -eq 0) {
    Write-Output 'All evals passed. Stopping.'
    break
  }

  if ($cycle -lt $MaxCycles) {
    $fixRunner = Join-Path $PSScriptRoot 'fix_runner.ps1'
    if (Test-Path $fixRunner) {
      & $fixRunner -RepoPath $RepoPath
    } else {
      Write-Output "Failures found. Review evals\test_report.txt, apply fixes, then press Enter to rerun."
      Read-Host
    }
  }
}
