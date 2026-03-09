# Headless Default Release Gate (Windows evidence)

- Status: **PENDING_REAL_RUN**
- Purpose: durable proof surface for the `P0 — Close the headless-default release gate with real Windows evidence` item.

## What is still required

- Run the default non-interactive path on a real Windows machine for both:
  - dry-run / smoke path
  - real default run
- Confirm by direct observation that no blocking `MsgBox` appears unless `--interactive` is passed.
- Confirm the scheduled/manual default path also stays headless.

## Verification commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`
- `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless -ScheduledTaskName "OneClickBackupDaily"`

## Current repo state

- Static headless guard exists: `scripts\CheckHeadlessDefault.ps1`
- Durable evidence capture entrypoint exists: `scripts\CaptureHeadlessEvidence.ps1`
- The evidence capture script can now also record `schtasks /Query` output when `-ScheduledTaskName` is supplied, so scheduled-task proof can live in the same durable markdown artifact.
- Checked-in Windows proof is still missing; this gate is not closed yet.

## Current blocker

- This repo is available through WSL at `/mnt/c/CORE/daily-ops-packager`, but the current OpenClaw automation session cannot launch native Windows binaries from here.
- Confirmed failing binaries in this pass: `powershell.exe`, `cmd.exe`, `AutoHotkey64.exe`
- Failure happens before the target process starts: `WSL ... UtilBindVsockAnyPort:307: socket failed 1`
- Result: the remaining PASS-grade evidence must be captured from a **native Windows terminal**, not from this WSL/OpenClaw session.

## Required human action

1. Open **Windows PowerShell** (not WSL) in `C:\CORE\daily-ops-packager`.
2. Review `config\app.ini` and only keep `-IncludeRealRun` if a real run is safe for the configured upload/email target.
3. Run:
   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless`
4. If the scheduled task already exists, rerun with the scheduler proof included:
   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless -ScheduledTaskName "OneClickBackupDaily"`
5. Commit the updated `docs\headless_default_release_gate.md` once it shows `Status: **PASS**`.
