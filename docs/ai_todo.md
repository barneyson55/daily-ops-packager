# AI TODO

Minimal AI task scaffold for daily-ops-packager.

- Keep this file as the durable backlog entrypoint.
- Current ASPM rotation priorities: `docs/aspm_ai_todo_2026-02-16.md`
- Last scaffold refresh: 2026-02-16 07:00 UTC


<!-- ASPM_SWEEP_2026-02-25 -->
## ASPM Sweep 2026-02-25
- [x] Portfolio sweep triage logged on branch `master` (pre-sweep repo state: `clean`).
- [x] First unchecked item in `docs/user_todo.md`: file-missing.
- [x] Top-level unchecked count in `docs/ai_todo.md` at sweep start: 0.
- [x] Add troubleshooting note for `docs/user_todo.md` vs `USER_TODO.md` path mismatch and document fallback behavior.
- [x] Create `docs/user_todo.md` pointer note to normalize automation entrypoint.

<!-- ASPM_SWEEP_2026-02-26 -->
## ASPM Sweep 2026-02-26
- [x] Advanced one concrete user-todo milestone: added `scripts/Init-Config.ps1` to bootstrap `config/app.ini` from sample.
- [x] Converted `USER_TODO.md` into checkbox-based progress tracker and linked step 4 to the new helper script.
- [x] Relevant check run: attempted `pwsh ... scripts/CheckPrereqs.ps1 -Config config/app.sample.ini` (blocked in this runner: `pwsh: not found`).

<!-- ASPM_SWEEP_2026-02-26T0244Z -->
## ASPM Sweep 2026-02-26T02:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding explicit `winget` install command for 7-Zip.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0344Z -->
## ASPM Sweep 2026-02-26T03:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding explicit `winget` install command for AutoHotkey v2.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0444Z -->
## ASPM Sweep 2026-02-26T04:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding explicit `winget` install command for rclone.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0544Z -->
## ASPM Sweep 2026-02-26T05:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding an explicit AutoHotkey verification command.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0644Z -->
## ASPM Sweep 2026-02-26T06:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding an explicit 7-Zip verification command.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0744Z -->
## ASPM Sweep 2026-02-26T07:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding an explicit `rclone version` verification command.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0844Z -->
## ASPM Sweep 2026-02-26T08:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 4 by adding explicit `Test-Path config\app.ini` verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 4.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T0944Z -->
## ASPM Sweep 2026-02-26T09:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 5 by adding explicit user-scope env-var verification guidance for `DAILY_ZIP_PASS` and `DAILY_SMTP_PASS`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 5.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1044Z -->
## ASPM Sweep 2026-02-26T10:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 6 by adding explicit `enabled = 1` verification guidance for the `[email]` config section.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 6.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1144Z -->
## ASPM Sweep 2026-02-26T11:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 7 by adding explicit fallback guidance to run prereq check via Windows PowerShell when `pwsh` is unavailable.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 7.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1244Z -->
## ASPM Sweep 2026-02-26T12:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 8 by adding explicit dry-run result verification guidance in `logs\summary_YYYYMMDD.csv`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 8.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1344Z -->
## ASPM Sweep 2026-02-26T13:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 9 by adding explicit real-run success verification guidance in `logs\summary_YYYYMMDD.csv`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 9.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1444Z -->
## ASPM Sweep 2026-02-26T14:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 10 by adding explicit scheduled-task run verification guidance (`schtasks /Run` + `Last Run Result: 0x0`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 10.
- [x] Relevant check run: `git diff --check` (pass).


<!-- ASPM_SWEEP_2026-02-26T1544Z -->
## ASPM Sweep 2026-02-26T15:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 11 by adding explicit latest-summary-line verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 11.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1644Z -->
## ASPM Sweep 2026-02-26T16:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding an explicit `rclone config create myremote local` example.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1744Z -->
## ASPM Sweep 2026-02-26T17:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 4 by adding concrete sample `config\app.ini` values for first-pass setup.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 4.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1844Z -->
## ASPM Sweep 2026-02-26T18:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding explicit PATH verification guidance (`where AutoHotkey64.exe`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T1944Z -->
## ASPM Sweep 2026-02-26T19:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding explicit `rclone listremotes` output validation (`myremote:` must appear).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T2044Z -->
## ASPM Sweep 2026-02-26T20:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding explicit PATH verification guidance for `7z.exe` (`where 7z.exe`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T2144Z -->
## ASPM Sweep 2026-02-26T21:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 6 by adding explicit SMTP required-field verification guidance (`host|port|username|from|to`) in `config\app.ini`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 6.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T2244Z -->
## ASPM Sweep 2026-02-26T22:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding explicit major-version verification guidance for AutoHotkey (`v2.x` check via `findstr`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-26T2344Z -->
## ASPM Sweep 2026-02-26T23:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding compact 7-Zip banner/version verification guidance (`7z.exe | findstr "^7-Zip"`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0044Z -->
## ASPM Sweep 2026-02-27T00:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding `winget list --id AutoHotkey.AutoHotkey -e` package-registration verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0144Z -->
## ASPM Sweep 2026-02-27T01:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 7 by adding explicit prereq-check exit-code verification guidance (`%ERRORLEVEL%` / `$LASTEXITCODE` must be `0`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 7.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0344Z -->
## ASPM Sweep 2026-02-27T03:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding explicit 7-Zip install-scope guidance (`--scope machine` if admin elevation is required).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0444Z -->
## ASPM Sweep 2026-02-27T04:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding explicit rclone install-scope guidance (`--scope machine` if admin elevation is required).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0544Z -->
## ASPM Sweep 2026-02-27T05:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 4 by adding explicit required-keys verification guidance for `watchDir|zip.exe|rclone.exe|rclone.remote` in `config\app.ini`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 4.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0644Z -->
## ASPM Sweep 2026-02-27T06:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 5 by adding active-session env-var refresh verification guidance after `setx`/`SetEnvironmentVariable`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 5.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0744Z -->
## ASPM Sweep 2026-02-27T07:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 11 by adding missing-file triage guidance before daily-summary tail verification.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 11.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0844Z -->
## ASPM Sweep 2026-02-27T08:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding `rclone config file` path verification guidance before first real run.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T0944Z -->
## ASPM Sweep 2026-02-27T09:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 8 by adding a quick PowerShell tail command to validate the freshest dry-run summary row immediately after execution.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 8.
- [x] Relevant check run: `git diff --check` (pass).


<!-- ASPM_SWEEP_2026-02-27T1044Z -->
## ASPM Sweep 2026-02-27T10:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 9 by adding a quick PowerShell tail command to validate the freshest real-run summary row immediately after execution.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 9.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1144Z -->
## ASPM Sweep 2026-02-27T11:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 10 by adding a `schtasks` next-run-time verification command for daily schedule sanity checks.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 10.
- [x] Relevant check run: `git diff --check` (pass).


<!-- ASPM_SWEEP_2026-02-27T1244Z -->
## ASPM Sweep 2026-02-27T12:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 6 by adding SMTP transport/port sanity guidance (587+STARTTLS or 465+implicit TLS).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 6.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1344Z -->
## ASPM Sweep 2026-02-27T13:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding unattended/silent `winget` install guidance for AutoHotkey v2.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1444Z -->
## ASPM Sweep 2026-02-27T14:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding post-install launcher resolution verification guidance for `AutoHotkey64.exe`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1544Z -->
## ASPM Sweep 2026-02-27T15:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding unattended/silent `winget` install guidance for 7-Zip.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1644Z -->
## ASPM Sweep 2026-02-27T16:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 10 by adding direct `schtasks /Create` CLI fallback guidance when XML import is not preferred.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 10.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1744Z -->
## ASPM Sweep 2026-02-27T17:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 5 by adding no-echo secret env-var presence verification guidance (values stay hidden).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 5.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1844Z -->
## ASPM Sweep 2026-02-27T18:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding explicit AutoHotkey64 file-version verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T1944Z -->
## ASPM Sweep 2026-02-27T19:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding explicit `winget list --id 7zip.7zip -e` package-registration verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T2044Z -->
## ASPM Sweep 2026-02-27T20:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding non-interactive remote health-check guidance (`rclone about myremote:` fallback `rclone lsd myremote:`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T2144Z -->
## ASPM Sweep 2026-02-27T21:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 7 by adding prereq transcript-capture guidance via `Tee-Object` into `logs\prereq_check_latest.log`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 7.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T2244Z -->
## ASPM Sweep 2026-02-27T22:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 11 by adding CSV-header sanity-check guidance before daily tail verification.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 11.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-27T2344Z -->
## ASPM Sweep 2026-02-27T23:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 7 by adding a command-resolution precheck for `AutoHotkey64.exe`, `7z.exe`, and `rclone.exe`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 7.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0044Z -->
## ASPM Sweep 2026-02-28T00:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 11 by adding daily summary row-count verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 11.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0144Z -->
## ASPM Sweep 2026-02-28T01:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 2 by adding explicit 7-Zip file-version verification guidance for `7z.exe`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 2.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0244Z -->
## ASPM Sweep 2026-02-28T02:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding `rclone config show myremote` profile sanity-check guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0344Z -->
## ASPM Sweep 2026-02-28T03:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding user-scope AutoHotkey install-path fallback verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0444Z -->
## ASPM Sweep 2026-02-28T04:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 1 by adding winget source reset/update fallback guidance before retrying AutoHotkey install.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 1.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0544Z -->
## ASPM Sweep 2026-02-28T05:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 8 by adding explicit dry-run exit-code verification guidance (`%ERRORLEVEL%` / `$LASTEXITCODE` must be `0`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 8.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0644Z -->
## ASPM Sweep 2026-02-28T06:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 9 by adding explicit real-run exit-code verification guidance (`%ERRORLEVEL%`/`$LASTEXITCODE` must be `0`).
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 9.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0744Z -->
## ASPM Sweep 2026-02-28T07:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 4 by adding path-existence verification guidance for `watchDir`, `zip.exe`, and `rclone.exe` values from `config\app.ini`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 4.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0844Z -->
## ASPM Sweep 2026-02-28T08:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 4 by adding resolved-value echo guidance for `watchDir|zip.exe|rclone.exe|rclone.remote` from `config\app.ini`.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 4.
- [x] Relevant check run: `git diff --check` (pass).

<!-- ASPM_SWEEP_2026-02-28T0944Z -->
## ASPM Sweep 2026-02-28T09:44Z
- [x] Open user todo handled (non-sensitive): advanced one concrete milestone on step 3 by adding `winget list --id Rclone.Rclone -e` package-registration verification guidance.
- [x] Updated `USER_TODO.md` checkboxes with completed guidance subtask under item 3.
- [x] Relevant check run: `git diff --check` (pass).
