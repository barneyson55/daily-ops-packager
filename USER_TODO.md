# User TODO (setup steps)

- [x] 0) Repo helper prepared: `scripts\Init-Config.ps1` added to bootstrap `config\app.ini` from sample.

- [ ] 1) Install AutoHotkey v2
  - Download and install AutoHotkey v2.

- [ ] 2) Install 7-Zip
  - [x] Added quick-install guidance (can be run in elevated PowerShell): `winget install --id 7zip.7zip -e`
  - Install 7-Zip and confirm `7z.exe` path, e.g.:
    - `C:\Program Files\7-Zip\7z.exe`

- [ ] 3) Install and configure rclone
  - Install rclone.
  - Run `rclone config` and create a remote (example: `myremote`).
  - Verify with `rclone listremotes`.

- [ ] 4) Create your config
  - Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Init-Config.ps1`
  - Edit `config\app.ini`:
    - `paths.watchDir` -> your source folder
    - `zip.exe` -> your 7-Zip path
    - `rclone.exe` -> your rclone path
    - `rclone.remote` -> your remote (e.g., `myremote:backups/daily`)

- [ ] 5) Set environment variables for secrets
  - Command Prompt:
    - `setx DAILY_ZIP_PASS "yourZipPassword"`
    - `setx DAILY_SMTP_PASS "yourSmtpPassword"`
  - PowerShell:
    - `[Environment]::SetEnvironmentVariable('DAILY_ZIP_PASS','yourZipPassword','User')`
    - `[Environment]::SetEnvironmentVariable('DAILY_SMTP_PASS','yourSmtpPassword','User')`
  - Log off/on to refresh env vars.

- [ ] 6) Optional: enable email notifications
  - In `config\app.ini` set `email.enabled=1` and fill SMTP details.

- [ ] 7) Run prereq check
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.ini`

- [ ] 8) Run a dry-run
  - `src\OneClickBackup.ahk --config config\app.ini --dry-run`
  - or run both prereq check + dry-run in one step:
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`

- [ ] 9) Run a real backup
  - `src\OneClickBackup.ahk --config config\app.ini`

- [ ] 10) Schedule it (Task Scheduler)
  - Create a daily task:
    - Program: `C:\Path\To\AutoHotkey64.exe`
    - Arguments: `C:\Path\To\repo\src\OneClickBackup.ahk --config C:\Path\To\repo\config\app.ini`
    - Start in: `C:\Path\To\repo`
  - Or use the template:
    - Edit `scripts\TaskScheduler-Daily.xml` placeholders:
      - `__AHK_EXE__`, `__AHK_ARGS__`, `__WORKING_DIR__`, `__START_BOUNDARY__` (e.g., `2026-01-25T09:00:00`)
    - Import with:
      - `schtasks /Create /TN "OneClickBackupDaily" /XML C:\Path\To\repo\scripts\TaskScheduler-Daily.xml /F`

- [ ] 11) Check daily summary report
  - `logs\summary_YYYYMMDD.csv` contains one line per run (status, counts, exit codes, message).
