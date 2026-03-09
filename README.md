# One-Click Daily Backup (AutoHotkey v2)

Small Windows automation that collects today's files from a watch directory, copies them to a temp workspace (preserving relative paths), creates a password-protected 7z archive, uploads it with rclone, and optionally sends an email notification.

## Quickstart
1) Install dependencies (see below).
2) Copy the sample config and edit it:
   - `config\app.sample.ini` -> `config\app.ini`
3) Set environment variables for secrets:
   - `DAILY_ZIP_PASS`
   - `DAILY_SMTP_PASS` (only if email is enabled)
4) Run a dry-run first:
   - headless/default: `src\OneClickBackup.ahk --config config\app.ini --dry-run`
   - manual desktop feedback: `src\OneClickBackup.ahk --config config\app.ini --dry-run --interactive`
   - static check for the headless default: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
   - or use the smoke test script: `scripts\SmokeTest.ps1 -Config config\app.ini`
   - durable Windows evidence capture (safe default, no real run; run this from native **Windows PowerShell**, not WSL): `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini`
   - durable Windows evidence capture with scheduler proof: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -ScheduledTaskName "OneClickBackupDaily"`
5) Run a real backup:
   - headless/default: `src\OneClickBackup.ahk --config config\app.ini`
   - manual desktop feedback: `src\OneClickBackup.ahk --config config\app.ini --interactive`

## Dependencies
- AutoHotkey v2
- 7-Zip (CLI: `7z.exe`)
- rclone
- PowerShell (built-in on Windows)

## Example commands
- Static headless-default guard:
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
- Durable Windows evidence capture:
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini`
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -ScheduledTaskName "OneClickBackupDaily"`
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ConfirmSafeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless`
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ConfirmSafeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless -ScheduledTaskName "OneClickBackupDaily"`
- Dry-run:
  - `src\OneClickBackup.ahk --config config\app.sample.ini --dry-run`
  - `src\OneClickBackup.ahk --config config\app.sample.ini --dry-run --interactive`
- Real run:
  - `src\OneClickBackup.ahk --config config\app.sample.ini`
  - `src\OneClickBackup.ahk --config config\app.sample.ini --interactive`

## Docs
- `docs\ARCHITECTURE.md`
- `docs\CONFIG.md`
- `docs\TROUBLESHOOTING.md`
- `docs\headless_default_release_gate.md`

## Evidence notes
- `scripts\CaptureHeadlessEvidence.ps1` writes the durable gate artifact to `docs\headless_default_release_gate.md`.
- The capture script now fails early with an exact native-Windows instruction when launched from a non-Windows host, including copy/paste-ready safe-first and PASS-grade rerun commands.
- The capture script also refuses `-IncludeRealRun` unless `-ConfirmSafeRealRun` is passed after reviewing `config\app.ini` safety.
- Each capture now includes a resolved config safety review (watch/output/tmp paths, upload/email targets, env-var readiness) before any optional real run.
- Each capture also writes a support transcript to `logs\headless_release_gate_YYYYMMDDTHHMMSS.log` by default (override with `-Transcript`).
- When `-ScheduledTaskName` is supplied, the same capture now audits the registered task action and fails if the task injects `--interactive`, stops targeting `OneClickBackup.ahk`, or drops the explicit config flag.
- The generated evidence now includes runtime context plus the latest `logs\backup_YYYYMMDD.log` tail alongside the headless guard, smoke-test, summary, and optional scheduler proof/action audit.

## Notes
- No secrets are stored in the repo; use environment variables.
- Scheduled/CLI runs are headless by default; pass `--interactive` only for manual desktop runs that should show dialogs.
- Source files are never modified. Temp files are only removed after a successful upload.
- Each run appends a summary line to `logs\summary_YYYYMMDD.csv`.
