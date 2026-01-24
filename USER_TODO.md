# User TODO (setup steps)

1) Install AutoHotkey v2
- Download and install AutoHotkey v2.

2) Install 7-Zip
- Install 7-Zip and confirm `7z.exe` path, e.g.:
  - `C:\Program Files\7-Zip\7z.exe`

3) Install and configure rclone
- Install rclone.
- Run `rclone config` and create a remote (example: `myremote`).
- Verify with `rclone listremotes`.

4) Create your config
- Copy `config\app.sample.ini` to `config\app.ini` and edit:
  - `paths.watchDir` -> your source folder
  - `zip.exe` -> your 7-Zip path
  - `rclone.exe` -> your rclone path
  - `rclone.remote` -> your remote (e.g., `myremote:backups/daily`)

5) Set environment variables for secrets
- Command Prompt:
  - `setx DAILY_ZIP_PASS "yourZipPassword"`
  - `setx DAILY_SMTP_PASS "yourSmtpPassword"`
- PowerShell:
  - `[Environment]::SetEnvironmentVariable('DAILY_ZIP_PASS','yourZipPassword','User')`
  - `[Environment]::SetEnvironmentVariable('DAILY_SMTP_PASS','yourSmtpPassword','User')`
- Log off/on to refresh env vars.

6) Optional: enable email notifications
- In `config\app.ini` set `email.enabled=1` and fill SMTP details.

7) Run prereq check
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.ini`

8) Run a dry-run
- `src\OneClickBackup.ahk --config config\app.ini --dry-run`

9) Run a real backup
- `src\OneClickBackup.ahk --config config\app.ini`

10) Schedule it (Task Scheduler)
- Create a daily task:
  - Program: `C:\Path\To\AutoHotkey64.exe`
  - Arguments: `C:\Path\To\repo\src\OneClickBackup.ahk --config C:\Path\To\repo\config\app.ini`
  - Start in: `C:\Path\To\repo`
