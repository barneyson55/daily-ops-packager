# User TODO (setup steps)

- [x] 0) Repo helper prepared: `scripts\Init-Config.ps1` added to bootstrap `config\app.ini` from sample.

- [ ] 1) Install AutoHotkey v2
  - [x] Added quick-install guidance (can be run in elevated PowerShell): `winget install --id AutoHotkey.AutoHotkey -e`
  - [x] Added verify step guidance: run `"C:\Program Files\AutoHotkey\AutoHotkey.exe" /ErrorStdOut /CP65001` (should print version/help without error).
  - [x] Added PATH verification guidance: run `where AutoHotkey64.exe` (should resolve to the installed AutoHotkey v2 binary path).
  - [x] Added major-version verification guidance: run `"C:\Program Files\AutoHotkey\AutoHotkey.exe" /ErrorStdOut /CP65001 | findstr /R "^v2\."` (should match a `v2.x` line).
  - [x] Added package-registration verification guidance: run `winget list --id AutoHotkey.AutoHotkey -e` (should show installed package/version).
  - [x] Added explicit install-scope guidance: if install requires admin rights, rerun with `winget install --id AutoHotkey.AutoHotkey -e --scope machine`; otherwise keep default user scope.
  - [x] Added silent-install guidance: append `--silent --accept-package-agreements --accept-source-agreements` to the winget command for unattended setup.
  - [x] Added post-install launcher verification guidance: run `Get-Command AutoHotkey64.exe | Select-Object -ExpandProperty Source` in PowerShell to confirm the resolved executable path.
  - [x] Added file-version verification guidance: run `powershell -NoProfile -Command "(Get-Item 'C:\Program Files\AutoHotkey\AutoHotkey64.exe').VersionInfo.FileVersion"` and confirm it returns a non-empty version string.
  - [x] Added user-scope install-path fallback guidance: if `C:\Program Files\AutoHotkey\AutoHotkey64.exe` is missing, run `powershell -NoProfile -Command "Get-ChildItem \"$env:LOCALAPPDATA\Programs\AutoHotkey\AutoHotkey64.exe\" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName"` and use the returned path for verification.
  - [x] Added winget source-refresh fallback guidance: if install/search fails, run `winget source reset --force` then `winget source update` before retrying AutoHotkey install.
  - Download and install AutoHotkey v2.

- [ ] 2) Install 7-Zip
  - [x] Added quick-install guidance (can be run in elevated PowerShell): `winget install --id 7zip.7zip -e`
  - [x] Added verify step guidance: run `"C:\Program Files\7-Zip\7z.exe" i` (should print 7-Zip version/build info without error).
  - [x] Added PATH verification guidance: run `where 7z.exe` (should resolve to the installed 7-Zip binary path).
  - [x] Added compact version-check guidance: run `"C:\Program Files\7-Zip\7z.exe" | findstr /R "^7-Zip"` (should print a `7-Zip` version banner line).
  - [x] Added explicit install-scope guidance: if install requires admin rights, rerun with `winget install --id 7zip.7zip -e --scope machine`; otherwise keep default user scope.
  - [x] Added silent-install guidance: append `--silent --accept-package-agreements --accept-source-agreements` to the winget command for unattended setup.
  - [x] Added package-registration verification guidance: run `winget list --id 7zip.7zip -e` (should show installed package/version).
  - [x] Added file-version verification guidance: run `powershell -NoProfile -Command "(Get-Item 'C:\Program Files\7-Zip\7z.exe').VersionInfo.FileVersion"` and confirm it returns a non-empty version string.
  - Install 7-Zip and confirm `7z.exe` path, e.g.:
    - `C:\Program Files\7-Zip\7z.exe`

- [ ] 3) Install and configure rclone
  - [x] Added quick-install guidance (can be run in elevated PowerShell): `winget install --id Rclone.Rclone -e`
  - [x] Added verify step guidance: run `rclone version` (should print version/build info without error).
  - [x] Added concrete remote-create example: `rclone config create myremote local` (quick local test remote; replace type/params later for cloud target).
  - [x] Added verify output guidance: run `rclone listremotes` and confirm `myremote:` appears in the output.
  - [x] Added explicit install-scope guidance: if install requires admin rights, rerun with `winget install --id Rclone.Rclone -e --scope machine`; otherwise keep default user scope.
  - [x] Added config-file verification guidance: run `rclone config file` and confirm the shown path exists before first real backup run.
  - [x] Added non-interactive remote health-check guidance: run `rclone about myremote:` (or `rclone lsd myremote:` when `about` is unsupported) to verify the remote is reachable before first real backup.
  - [x] Added config-file profile sanity-check guidance: run `rclone config show myremote` (or `rclone config dump --config "$(rclone config file | Select-String -Pattern 'rclone\.conf' | ForEach-Object { $_.ToString().Split(':',2)[1].Trim() })"`) and confirm the remote points to the intended backend/path before enabling scheduled runs.
  - Install rclone.
  - Run `rclone config` and create a remote (example: `myremote`).
  - Verify with `rclone listremotes`.

- [ ] 4) Create your config
  - [x] Added verify step guidance: run `powershell -NoProfile -Command "Test-Path config\app.ini"` (should return `True` after init script).
  - [x] Added concrete sample values guidance for quick first edit: `paths.watchDir=C:\DailySource`, `zip.exe=C:\Program Files\7-Zip\7z.exe`, `rclone.exe=C:\Program Files\rclone\rclone.exe`, `rclone.remote=myremote:backups/daily`.
  - [x] Added required-keys verification guidance: run `powershell -NoProfile -Command "Select-String -Path config\app.ini -Pattern '^(watchDir|zip\.exe|rclone\.exe|rclone\.remote)\s*=\s*.+$' -SimpleMatch:$false"` and confirm all four keys are present with non-empty values.
  - Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Init-Config.ps1`
  - Edit `config\app.ini`:
    - `paths.watchDir` -> your source folder
    - `zip.exe` -> your 7-Zip path
    - `rclone.exe` -> your rclone path
    - `rclone.remote` -> your remote (e.g., `myremote:backups/daily`)

- [ ] 5) Set environment variables for secrets
  - [x] Added verify step guidance: run `powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('DAILY_ZIP_PASS','User'); [Environment]::GetEnvironmentVariable('DAILY_SMTP_PASS','User')"` (both should print non-empty values).
  - [x] Added current-session refresh guidance: after setting vars, restart terminal (or launch a new shell) then run `echo %DAILY_ZIP_PASS%` / `echo %DAILY_SMTP_PASS%` to confirm values are loaded in the active session.
- [x] Added no-echo verification guidance for secrets in PowerShell: run `powershell -NoProfile -Command "$a=[Environment]::GetEnvironmentVariable('DAILY_ZIP_PASS','User');$b=[Environment]::GetEnvironmentVariable('DAILY_SMTP_PASS','User'); if([string]::IsNullOrWhiteSpace($a)-or[string]::IsNullOrWhiteSpace($b)){Write-Error 'Missing secret env var'} else {'Secrets present (values hidden)'}"` to confirm presence without printing secret values.
  - Command Prompt:
    - `setx DAILY_ZIP_PASS "yourZipPassword"`
    - `setx DAILY_SMTP_PASS "yourSmtpPassword"`
  - PowerShell:
    - `[Environment]::SetEnvironmentVariable('DAILY_ZIP_PASS','yourZipPassword','User')`
    - `[Environment]::SetEnvironmentVariable('DAILY_SMTP_PASS','yourSmtpPassword','User')`
  - Log off/on to refresh env vars.

- [ ] 6) Optional: enable email notifications
  - [x] Added verify step guidance: run `powershell -NoProfile -Command "Select-String -Path config\app.ini -Pattern '^enabled\s*=\s*1$' -SimpleMatch:$false"` from the `[email]` section context (should show `enabled = 1`).
  - [x] Added concrete SMTP field verification guidance: run `powershell -NoProfile -Command "Select-String -Path config\app.ini -Pattern '^(host|port|username|from|to)\s*=\s*.+$' -SimpleMatch:$false"` and confirm all required email fields appear with non-empty values.
  - [x] Added SMTP transport sanity-check guidance: keep `port=587` with STARTTLS enabled (or `port=465` with implicit TLS) to avoid common auth/handshake failures.
  - In `config\app.ini` set `email.enabled=1` and fill SMTP details.

- [ ] 7) Run prereq check
  - [x] Added fallback guidance: if `pwsh` is unavailable, run with Windows PowerShell (`powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.ini`).
  - [x] Added exit-code verification guidance: after the prereq command, run `echo %ERRORLEVEL%` (or `powershell -NoProfile -Command "$LASTEXITCODE"`) and confirm it is `0`.
  - [x] Added transcript-capture guidance: run `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.ini *>&1 | Tee-Object -FilePath logs\prereq_check_latest.log` to keep a troubleshooting log copy.
  - [x] Added binary-resolution precheck guidance: run `powershell -NoProfile -Command "Get-Command AutoHotkey64.exe,7z.exe,rclone.exe | Select-Object Name,Source"` before prereq script and confirm all three commands resolve.
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.ini`

- [ ] 8) Run a dry-run
  - [x] Added verify step guidance: confirm latest line in `logs\summary_YYYYMMDD.csv` reports a dry-run status (for example, contains `dry-run`/`DRY_RUN` and no fatal error message).
  - [x] Added quick tail command guidance for dry-run verification: run `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"` right after dry-run to inspect the freshest status row.
  - `src\OneClickBackup.ahk --config config\app.ini --dry-run`
  - or run both prereq check + dry-run in one step:
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`

- [ ] 9) Run a real backup
  - [x] Added verify step guidance: check latest line in `logs\summary_YYYYMMDD.csv` shows a successful non-dry-run upload/archive result (for example contains `OK`/`SUCCESS` and not `DRY_RUN`).
  - [x] Added quick tail command guidance for real-run verification: run `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"` right after real backup to confirm the newest success row.
  - `src\OneClickBackup.ahk --config config\app.ini`

- [ ] 10) Schedule it (Task Scheduler)
  - [x] Added verify step guidance: trigger once with `schtasks /Run /TN "OneClickBackupDaily"` then query `schtasks /Query /TN "OneClickBackupDaily" /V /FO LIST` and confirm `Last Run Result: 0x0`.
  - [x] Added schedule-time verification guidance: run `schtasks /Query /TN "OneClickBackupDaily" /V /FO LIST | findstr /I "Schedule Next Run Time"` and confirm the next run slot matches your intended daily window.
  - [x] Added direct CLI-create fallback guidance: `schtasks /Create /SC DAILY /TN "OneClickBackupDaily" /TR "\"C:\Path\To\AutoHotkey64.exe\" \"C:\Path\To\repo\src\OneClickBackup.ahk\" --config \"C:\Path\To\repo\config\app.ini\"" /ST 09:00 /F` when XML import is not preferred.
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
  - [x] Added missing-file triage guidance: if today's `logs\summary_YYYYMMDD.csv` is absent, run one dry-run first, then re-run the tail command to validate line format.
  - [x] Added verify step guidance: run `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"` and confirm the line includes timestamp + status fields (and no parse/error text).
  - [x] Added CSV-header sanity-check guidance: run `powershell -NoProfile -Command "$h=(Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -TotalCount 1); if($h -match 'timestamp' -and $h -match 'status'){ 'Header OK' } else { Write-Error 'Unexpected or missing header' }"` before tail checks.
  - [x] Added daily-row-count verification guidance: run `powershell -NoProfile -Command "(Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv | Measure-Object -Line).Lines"` and confirm it grows after each run.
  - `logs\summary_YYYYMMDD.csv` contains one line per run (status, counts, exit codes, message).
