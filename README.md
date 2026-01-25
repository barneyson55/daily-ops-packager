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
   - `src\OneClickBackup.ahk --config config\app.ini --dry-run`
   - or use the smoke test script: `scripts\SmokeTest.ps1 -Config config\app.ini`
5) Run a real backup:
   - `src\OneClickBackup.ahk --config config\app.ini`

## Dependencies
- AutoHotkey v2
- 7-Zip (CLI: `7z.exe`)
- rclone
- PowerShell (built-in on Windows)

## Example commands
- Dry-run:
  - `src\OneClickBackup.ahk --config config\app.sample.ini --dry-run`
- Real run:
  - `src\OneClickBackup.ahk --config config\app.sample.ini`

## Docs
- `docs\ARCHITECTURE.md`
- `docs\CONFIG.md`
- `docs\TROUBLESHOOTING.md`

## Notes
- No secrets are stored in the repo; use environment variables.
- Source files are never modified. Temp files are only removed after a successful upload.
- Each run appends a summary line to `logs\summary_YYYYMMDD.csv`.
