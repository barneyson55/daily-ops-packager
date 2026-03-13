# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-13 08:26 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`).
- Re-verified GitHub Actions run `23039582037` from this repo root in the same pass that refreshed the stale operator-facing status docs:
  - `gh run list --workflow windows-regression.yml --limit 5` shows latest run `23039582037` succeeded on `master`.
  - `gh api repos/barneyson55/daily-ops-packager/actions/runs/23039582037` confirms `conclusion: success` for commit `4ed16802a533c52f1d46870eba6b597a370cf782`.
  - `gh run download 23039582037 --dir tmp/windows-regression-success` re-downloaded the retained artifact bundle.
  - `gh api repos/barneyson55/daily-ops-packager/actions/runs/23039582037/artifacts` returns `total_count: 1` for `windows-regression-23039582037-1`.
  - The downloaded bundle contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
  - `regression.log` contains `Resolved AutoHotkey v2 executable:` and `Regression suite OK.` and omits the old AutoHotkey v1 mismatch strings.
- `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` were refreshed in the same pass and no longer claim `only failures` / `0 artifacts`.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the native Windows PASS artifact remains the checked-in release blocker.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Do **not** leave a native-Windows-only or human-observation-only task in slot 1 while an agent-actionable repo task is still open.
- Prefer items that either remove stale operator risk or unlock the next evidence step.
- Every item must end with a clear verification block that can pass or fail.

## Recently completed

- [x] **P1 — Re-verify run `23039582037` and immediately refresh the stale status surfaces in the same pass**
  - Completed at `2026-03-13 08:26 UTC`.
  - Result: the post-fix green run was rechecked live, the expected artifact bundle was re-downloaded and inspected, and `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` were updated together to match that evidence while keeping the native Windows PASS gate open.

## Prioritized open items

- [ ] **P2 — Reduce status-doc drift so `docs/status.md` stays canonical and the other surfaces stop carrying independent histories**
  - **Why this is first now:** the stale status story has been corrected, so the next highest-leverage step is preventing the same drift from reappearing.
  - **Deliverables:**
    - Keep `docs/status.md` as the detailed release/evidence narrative.
    - Trim repo-root `STATUS.md` to a short operator summary that points back to `docs/status.md`.
    - Keep `docs/critical_todo.md` limited to true blockers only, without replaying the full CI history there.
    - Update `docs/deep_research_auto.md` if needed so it no longer contradicts the refreshed queue/state.
  - **Verification:**
    - `rg -n "only failures|0 artifacts|23031883329|23037310780|23039582037|PENDING_REAL_RUN" STATUS.md docs/status.md docs/critical_todo.md docs/deep_research_auto.md docs/ai_todo.md`
    - Manual review confirms:
      - `docs/status.md` is the detailed canonical narrative
      - `STATUS.md` is short and points to the canonical doc
      - `docs/critical_todo.md` lists blockers without carrying a second full status essay
      - `docs/deep_research_auto.md`, if updated, no longer contradicts the active queue
  - **Current blocker:** none.

- [ ] **P3 — Collapse the duplicate static-guard surface so `CheckHeadlessDefault.ps1` is the only canonical entrypoint**
  - **Why this is second now:** this is still repo-actionable from the current environment, and the extra script name keeps reappearing in docs/research surfaces even though the real call sites already converge on `CheckHeadlessDefault.ps1`.
  - **Deliverables:**
    - Remove or clearly deprecate `scripts\VerifyNonInteractiveDefault.ps1`.
    - Update any remaining docs/tests/callers so there is exactly one canonical static headless guard name.
    - Ensure regression/evidence scripts and operator docs all point to the same command surface.
  - **Verification:**
    - `rg -n "VerifyNonInteractiveDefault|CheckHeadlessDefault" -S .`
    - Manual review confirms either:
      - `VerifyNonInteractiveDefault.ps1` is gone, or
      - it is explicitly marked as a compatibility shim and no canonical docs point to it.
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
  - **Current blocker:** none.

- [ ] **P4 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is third now:** this remains the checked-in release blocker, but it stays behind still-open repo-actionable work so Autopilot does not dead-end on a human-observation task while repo-side cleanup is still available.
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

- The queue stays intentionally short: one anti-drift docs cleanup, one remaining repo-actionable script-surface cleanup, then the still-open native Windows release gate.
- The main completed step in this pass was deliberate: **status-surface repair was fused into the live artifact re-check** so the checked-in repo narrative now matches the current CI evidence.
