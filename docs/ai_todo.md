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
