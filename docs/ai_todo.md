# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-13 09:54 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager`.
- `git status --short --branch` is clean: `## master...origin/master`.
- `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- Current canonical status story remains:
  - `docs/status.md` says the latest sampled Windows regression run `23039582037` succeeded on `master` and exposed a downloadable artifact bundle.
  - That bundle contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
  - `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the native Windows PASS artifact remains the checked-in release blocker.
- `scripts/VerifyNonInteractiveDefault.ps1` still exists as a thin wrapper over `scripts/CheckHeadlessDefault.ps1`, so the static-guard surface is not fully collapsed yet.
- `docs/deep_research_auto.md` needed refresh so it no longer acts like a competing status feed with older failure-led conclusions.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Keep native-Windows-only or human-observation-only work below still-open repo-actionable items.
- Every item must end with a clear verification block that can pass or fail.

## Recently completed

- [x] **Re-validate the doc set at the exact repo root and re-order this queue around the still-open repo-actionable work**
  - Completed at `2026-03-13 09:54 UTC`.
  - Result: confirmed clean git status, confirmed the expected docs files exist, and moved the duplicate static-guard cleanup ahead of the human/native-Windows-only release gate.

## Prioritized open items

- [ ] **P1 — Collapse the duplicate static-guard surface so `scripts\CheckHeadlessDefault.ps1` is the only canonical entrypoint**
  - **Why this is first now:** this is the highest-leverage repo-actionable engineering cleanup still open; it removes naming drift across scripts and docs and makes the release-evidence story easier to maintain.
  - **Deliverables:**
    - Remove `scripts\VerifyNonInteractiveDefault.ps1`, or demote it to explicit compatibility-shim status.
    - Update any remaining docs, tests, or callers so canonical guidance points only to `scripts\CheckHeadlessDefault.ps1`.
    - Keep regression and evidence scripts passing against the single canonical guard surface.
  - **Verification:**
    - `rg -n "VerifyNonInteractiveDefault|CheckHeadlessDefault" -S .`
    - Manual review confirms either:
      - `scripts\VerifyNonInteractiveDefault.ps1` is gone, or
      - it is clearly labeled as a compatibility shim and no canonical docs/tests depend on its name.
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
  - **Current blocker:** none from current repo state; requires a future code/docs pass outside this docs-only maintenance update.

- [ ] **P2 — Keep the status surfaces aligned so `docs/status.md` stays canonical and the supporting docs do not drift again**
  - **Why this is second now:** stale operator docs can mis-prioritize engineering work, but this stays behind the script-surface cleanup because it is lower leverage than removing the duplicate guard entrypoint.
  - **Deliverables:**
    - Keep `docs/status.md` as the detailed release/evidence narrative.
    - Keep `docs/critical_todo.md` limited to true blockers only.
    - Keep `docs/ai_todo.md` as the short actionable queue.
    - Refresh `docs/deep_research_auto.md` only as supporting analysis, not as a competing status feed.
  - **Verification:**
    - `rg -n "only failures|0 artifacts|23031883329|23039582037|PENDING_REAL_RUN|VerifyNonInteractiveDefault" STATUS.md docs/status.md docs/critical_todo.md docs/deep_research_auto.md docs/ai_todo.md`
    - Manual review confirms:
      - `docs/status.md` is the detailed canonical narrative
      - `STATUS.md` is short and points back to the canonical doc
      - `docs/critical_todo.md` lists only blockers
      - `docs/deep_research_auto.md` does not contradict the active queue/current status
  - **Current blocker:** none.

- [ ] **P3 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is third now:** this is still the real checked-in release blocker, but it stays below remaining repo-actionable work because it requires native Windows plus human observation.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so scheduler-query output and action-audit evidence land in the same artifact.
    - Rerun in `-Mode Pass -ObservedBy "YourName"`, preserve the newest `logs\headless_release_gate_*.log`, and update `docs\headless_default_release_gate.md` from `PENDING_REAL_RUN` to `PASS`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:|OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal plus human desktop observation; cannot be closed from this WSL/OpenClaw session.

## Notes

- The queue is intentionally short: one remaining repo-actionable script-surface cleanup, one status anti-drift item, then the still-open native Windows release gate.
- This maintenance pass changed docs only.
