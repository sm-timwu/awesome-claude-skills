---
name: layercake-eval
description: This skill should be used to run Layercake evals by starting the Layercake server in the background, running evals\eval_runner.py, and surfacing new eval reports from evals\reports.
---

# Run Layercake Eval

## Overview

Run evaluation tests against the Layercake server. Start the server in the background, wait for a healthy response, run the eval runner, then list new or updated report files.

## Quick Start

Run the helper script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_layercake_eval.ps1
```

## Manual Workflow

1. Start the Layercake server in the background by invoking the run-layercake-server skill or its helper script:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\tim.wu\.codex\skills\run-layercake-server\scripts\run_layercake.ps1
```

2. Wait for `http://localhost:5001/health` to return a healthy response.
3. Change directory to `D:\Repositories\SoulMachinesGIT\skill-layercake`.
4. Activate the venv using `venv\Scripts\Activate.ps1`.
5. Run `python evals\eval_runner.py` and wait for it to complete.
6. Inspect `evals\reports` and surface report files created or modified after the eval runner started.

## Resources

- `scripts/run_layercake_eval.ps1`: Start server, wait for health, run eval runner, list new report files.
