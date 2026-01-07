---
name: layercake-server
description: This skill should be used to start the Layercake server locally by activating its virtual environment and running skill_server.py in D:\Repositories\SoulMachinesGIT\skill-layercake.
---

# Run Skill Layercake

## Overview

Start the Layercake skill server on port 5001 by switching to the repo, activating the local venv, and running the server entrypoint.

## Quick Start

Run the helper script to launch the server:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_layercake.ps1
```

## Manual Workflow

1. Change directory to `D:\Repositories\SoulMachinesGIT\skill-layercake`.
2. Activate the venv using `venv\Scripts\Activate.ps1`.
3. Run `python skill_server.py`.

Fail with the error from the shell if the venv or `skill_server.py` is missing.

## Resources

- `scripts/run_layercake.ps1`: PowerShell helper that performs the workflow and fails fast if required files are missing.
