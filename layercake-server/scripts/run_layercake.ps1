param(
  [string]$RepoPath = 'D:\Repositories\SoulMachinesGIT\skill-layercake'
)

$activatePath = Join-Path $RepoPath 'venv\Scripts\Activate.ps1'
$serverPath = Join-Path $RepoPath 'skill_server.py'

if (!(Test-Path $RepoPath)) {
  throw "Repo not found: $RepoPath"
}

if (!(Test-Path $activatePath)) {
  throw "Virtualenv activation script not found: $activatePath"
}

if (!(Test-Path $serverPath)) {
  throw "skill_server.py not found: $serverPath"
}

Set-Location $RepoPath
. $activatePath
python $serverPath
