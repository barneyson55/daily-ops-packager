# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-13 07:14 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` shows only the existing docs worktree edits from this maintenance stream.
- Repo status docs are still split:
  - `docs/status.md`, `docs/critical_todo.md`, and repo-root `STATUS.md` still describe the older `only failures / zero artifacts` picture.
  - `docs/ai_todo.md` and `docs/deep_research_auto.md` had already been tracking the CI repair thread more closely.
- P0 is now effectively closed on current `master`:
  - latest run `23039582037` on commit `4ed1680` finished `success`
  - job `66914844724` shows `Install AutoHotkey v2`, `Prepare regression artifact directory`, and `Run regression suite` all concluded `success`
  - the run log contains `Resolved AutoHotkey v2 at C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
  - the run log does **not** contain `Script file not found`
- The live failure-to-success transition is now clear:
  - failed run `23037310780` no longer hit the old bare-executable `Script file not found` bug; it printed `2.0.21` and then failed because the probe regex still required a literal `v` prefix
  - commit `4ed1680` changed the probe regex to accept either `v2.x` or `2.x`, and the immediately following run `23039582037` went green
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the native Windows PASS artifact remains the checked-in release blocker.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Do **not** leave a native-Windows-only or human-observation-only task in slot 1 while an agent-actionable repo task is still open.
- Keep blocked external work visible, but place it behind any still-open repo task that Autopilot can execute from this environment.
- Every item must end with a clear verification block that can pass or fail.

## Prioritized open items

- [ ] **P1 — Re-verify the fresh green `windows-regression.yml` artifact bundle from run `23039582037`**
  - **Why this is first:** current `master` already has the post-fix green run, so the next highest-value proof is downloading that exact success artifact bundle and confirming the expected files/runtime evidence are really there.
  - **Deliverables:**
    - Use successful run `23039582037` as the post-fix reference run on current `master`.
    - Confirm the success-path artifact bundle still contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - Confirm `regression.log` still includes `Resolved AutoHotkey v2 executable:` and `Regression suite OK.` while keeping the v1-mismatch text absent.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh run download 23039582037 --dir tmp/windows-regression-success`
    - `python3 - <<'PY'
from pathlib import Path
base = Path('tmp/windows-regression-success')
log = next(base.glob('**/regression.log'))
summary = next(base.glob('**/regression-summary.md'))
ctx = next(base.glob('**/workflow-context.txt'))
assert log.is_file() and summary.is_file() and ctx.is_file()
raw = log.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Resolved AutoHotkey v2 executable:' in text
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** none.

- [ ] **P2 — Refresh `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` once the post-fix artifact re-check lands so operator docs match reality again**
  - **Why this is second:** the operator-facing status surfaces are stale right now. After the fresh success artifact bundle is re-verified, refreshing them has high near-term value because it restores truthful release communication across the repo and stays actionable from the repo side.
  - **Deliverables:**
    - Remove the outdated `only failures` / `0 artifacts` framing.
    - Record that truthful skipped-run artifacts are already proven by failed runs `23031883329` and `23037310780`.
    - Record the AutoHotkey install-step probe break and then replace it with the post-fix, post-green-run state backed by run `23039582037` once the artifact re-check is complete.
    - Preserve the distinction between CI regression confidence and the still-open native Windows PASS gate until P4 closes.
  - **Verification:**
    - `grep -n "only failure\|only failures\|0 artifacts\|zero stored Actions artifacts\|total_count.:0" STATUS.md docs/status.md docs/critical_todo.md`
    - `grep -n "23039582037\|23037310780\|23031883329\|pre-regression-failure.txt\|Install AutoHotkey v2\|Script file not found" STATUS.md docs/status.md docs/critical_todo.md`
    - Manual diff review confirms the docs no longer claim the obsolete `all failures / zero artifacts` state.
    - Manual diff review confirms native Windows PASS evidence remains the checked-in release blocker until P4 closes.
  - **Current blocker:** best done after the `23039582037` artifact bundle is re-verified so the docs can point to a fully checked post-fix success state.

- [ ] **P3 — Collapse the duplicate static-guard surface so `CheckHeadlessDefault.ps1` is the only canonical entrypoint**
  - **Why this is third:** this is still repo-actionable from the current environment, and it should stay ahead of the native-Windows-only gate so Autopilot does not stall on a human-observation task while repo cleanup remains open.
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
  - **Why this is fourth:** this remains the checked-in release blocker, but it is intentionally kept behind still-open repo-actionable work so the queue stays continuously executable from this WSL/OpenClaw session. Pull it forward manually as soon as a native Windows operator is available.
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

- The queue stays intentionally short: one post-fix artifact re-check, two remaining repo-actionable follow-ups, then the still-open native Windows release gate.
- The main ordering change in this pass is deliberate: **the remaining repo-actionable work stays ahead of the native-Windows PASS gate** so Autopilot does not dead-end on a human-only task while repo-side work is still open.
- No source-code changes were made in this maintenance pass; this file was refreshed from repo status plus live GitHub evidence only.
