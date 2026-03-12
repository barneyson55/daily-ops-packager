# Headless Default Release Gate (Windows evidence)

- Status: **PENDING_REAL_RUN**
- Purpose: durable proof surface for the `P0 — Close the headless-default release gate with real Windows evidence` item.

## What is still required

- Run the default non-interactive path on a real Windows machine for both:
  - dry-run / smoke path
  - real default run
- Confirm by direct observation that no blocking `MsgBox` appears unless `--interactive` is passed.
- If `OneClickBackupDaily` already exists, also capture scheduler proof and optionally note any direct scheduled/manual headless observation.

## Verification commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini` (explicit opt-in to your local config)
- `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`

## Current repo state

- Static headless guard exists: `scripts\CheckHeadlessDefault.ps1`
- Durable evidence capture entrypoint exists: `scripts\CaptureHeadlessEvidence.ps1`
- Short-form native Windows wrapper exists: `scripts\RunHeadlessEvidenceCapture.ps1`
- The evidence capture script now fails early with an exact native-Windows instruction when launched from a non-Windows host, including copy/paste-ready safe-first and PASS-grade rerun commands.
- The evidence capture script now defaults to the repo-local readiness fixture-backed smoke path, matching `scripts\SmokeTest.ps1` with no arguments.
- The evidence capture script also refuses `-IncludeRealRun` unless `-ConfirmSafeRealRun` is supplied after reviewing the selected config's safety; use `-Config config\app.ini` only when you intentionally want live/local evidence.
- Each capture now also records a resolved config safety review (watch/output/tmp paths, remote/email targets, and env-var readiness) before the optional real run.
- Each capture now also writes a support transcript to `logs\headless_release_gate_YYYYMMDDTHHMMSS.log` by default.
- The evidence capture script can now also record `schtasks /Query` output when `-ScheduledTaskName` is supplied, so scheduled-task proof can live in the same durable markdown artifact.
- The same scheduler-aware capture now also audits the registered task action and fails if the task injects `--interactive`, stops targeting `OneClickBackup.ahk`, or drops the explicit config flag.
- PASS-grade observation flags now require `-ObservedBy "YourName"` so the resulting artifact records who directly confirmed the headless behavior.
- In `-Mode Pass`, the short-form wrapper now auto-runs `scripts\AssertHeadlessReleaseGate.ps1` against the same output path, and fails if the generated markdown is still missing PASS-grade evidence.
- Checked-in Windows proof is still missing; this gate is not closed yet.

## Current blocker

- This repo is available through WSL at `/mnt/c/CORE/daily-ops-packager`, but the current OpenClaw automation session still cannot run the native Windows binaries needed for the final proof.
- Re-verified in this pass from the repo root:
  - `pwsh` is not installed in this Linux/WSL session.
  - `powershell.exe`, `cmd.exe`, and `AutoHotkey64.exe` are not callable here (`Command not found`).
- Result: the remaining PASS-grade evidence must be captured from a **native Windows terminal**, not from this WSL/OpenClaw session.

## Required human action

1. Open **Windows PowerShell** (not WSL) in `C:\CORE\daily-ops-packager`.
2. Run the safe first pass so the artifact captures guard + the fixture-backed smoke/default path + config-safety context before any live backup:
   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
3. If you want evidence against your real/local config instead of the repo-local fixture, rerun with `-Config config\app.ini` and review that config before any real run:
   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Config config\app.ini`
4. Run the PASS-grade capture after directly observing the default path stay headless. On success, this wrapper now auto-runs the PASS assert against the same output file:
   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
5. If the scheduled task already exists, rerun with the scheduler proof included so the artifact also captures `schtasks` output and the task-action audit (append `-ObservedScheduledTaskHeadless` only if you directly watched that path stay headless). The same PASS wrapper will then require scheduler-query evidence too:
   - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
6. If you want PASS-grade evidence against your real/local config, add `-Config config\app.ini` to the same PASS command after confirming that run is safe for the configured upload/email target.
7. If you need to re-check the artifact later without rerunning the capture, execute `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`.
8. Commit the updated `docs\headless_default_release_gate.md` once it shows `Status: **PASS**` and records `Observed by: **YourName**`.
