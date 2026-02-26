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
