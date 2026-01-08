---
name: layercake-eval-fix
description: This skill should be used to run Layercake evals, analyze failed metrics against transcripts, write a consolidated test report, plan fixes in the skill-layercake repo, implement them, and repeat up to three cycles.
---

# Layercake Eval Fix

## Overview

Run Layercake evals, analyze failures against transcripts, write a consolidated test report, plan fixes in `D:\Repositories\SoulMachinesGIT\skill-layercake`, implement changes, and repeat until metrics pass or three cycles are complete.

## Workflow

1. Change directory to `D:\Repositories\SoulMachinesGIT\skill-layercake` and activate the venv with `venv\Scripts\Activate.ps1`.
2. Start Layercake evals in a separate PowerShell window. Prefer running the existing helper script:

```powershell
Start-Process -FilePath powershell -ArgumentList @(
  '-NoProfile',
  '-ExecutionPolicy', 'Bypass',
  '-File', 'C:\Users\tim.wu\.codex\skills\layercake-eval\scripts\run_layercake_eval.ps1'
) -PassThru -WindowStyle Normal
```

Wait for the eval process to finish before continuing.

3. Automate eval runs and report generation when possible by using the provided scripts:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\tim.wu\.codex\skills\layercake-eval-fix\scripts\run_eval_cycle.ps1
```

4. Inspect new or updated `*.txt` reports in `evals\reports`. For each report, identify test cases where one or more metrics fail. If a report contains multiple failing test cases, start with the one that has the most failed metrics.
5. For each failing test case, locate the corresponding transcript in `evals\debug`. Use the session id from the report to form the transcript name:

```
eval_transcript_{Session ID}.txt
```

Example: session id `eval_session_5d8f46b1-4d2d-48c7-bc48-66ccc6e42abb` maps to
`eval_transcript_eval_session_5d8f46b1-4d2d-48c7-bc48-66ccc6e42abb.txt`.

6. Read the transcript carefully and compare it to the failed metrics. Identify the concrete reason for each failure.
7. Repeat steps 4-6 for all remaining failing test cases across all new reports.
8. Summarize all issues in a single consolidated report at `evals\test_report.txt`. Combine similar errors into one issue. Include at least:
   - Report file and test case id
   - Session id and transcript file
   - Failed metrics and evidence from the transcript
   - Root cause hypothesis
9. Based on `evals\test_report.txt`, write a plan to fix the relevant scripts in `D:\Repositories\SoulMachinesGIT\skill-layercake`. Ignore `venv` and `blackboard` unless referencing library code. Implement the plan and add or update unit/integration tests as needed.
10. After making changes, restart layercake-server by closing both the server and eval PowerShell windows, then re-run the eval skill.
11. Re-run evals and repeat steps 2-11 until either all failed metrics are fixed or three total cycles have been completed. Track the cycle count and stop at three.

## Scripts

- `scripts/run_eval_cycle.ps1`: Run evals in a separate window, build `evals\test_report.txt`, and loop up to three cycles.
- `scripts/fix_runner.ps1`: Open the repo, prompt to review `evals\test_report.txt`, then pause for manual fixes.
- `scripts/parse_reports.ps1`: Parse report files and extract failing test cases and metrics.
- `scripts/build_test_report.ps1`: Generate `evals\test_report.txt` by combining report data with transcript evidence.

## References

- `references/report_schema.md`: Report parsing and transcript mapping notes.
- `references/fix_checklist.md`: Checklist to follow before rerunning evals.
