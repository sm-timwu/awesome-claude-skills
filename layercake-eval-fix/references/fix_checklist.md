# Fix Checklist

Use this checklist before re-running evals:

- Review `evals\test_report.txt` for all issues and failed metrics.
- Locate the relevant script(s) in `D:\Repositories\SoulMachinesGIT\skill-layercake` (ignore `venv` and `blackboard`).
- Implement the fix and update or add tests if needed.
- Run any local unit or integration tests you added.
- Ensure any new or updated files are saved.
- Close the layercake-server and eval PowerShell windows to restart the server.
- Re-run the eval skill to restart layercake-server before the next cycle.
