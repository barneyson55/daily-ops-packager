# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 19:44 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only maintenance pass: `## master...origin/master`.
- Fresh GitHub Actions evidence now shows **two newer successful** `windows-regression.yml` runs after the earlier failures: `23018180172` and `23014208204`.
- Downloaded artifact bundles for both success runs each contain all three expected files:
  - `regression.log`
  - `regression-summary.md`
  - `workflow-context.txt`
- Both fresh `regression.log` files now show the right runtime story:
  - resolved AutoHotkey v2 executable: `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
  - contains `Regression suite OK.`
  - does **not** contain `This script requires AutoHotkey v2.0.`
  - does **not** contain `Current interpreter: AutoHotkey v1`
  - does **not** contain `AutoHotkey v2 executable not found after Chocolatey install.`
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the checked-in native Windows release proof is still missing.
- `docs/status.md` and `docs/critical_todo.md` are now stale in a decision-relevant way: they still describe an earlier `only failures` / `0 artifacts` state that is no longer accurate.

## Queueing rule for this file

- Keep only 3-7 concrete open items.
- Order by engineering leverage, not by easiest docs edit.
- Every item must end with a clear verification block that can pass or fail.
- Treat stale doc sync as a trailing task unless it changes operator decisions right now.

## Prioritized open items

- [ ] **P0 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is first:** fresh CI is back, artifact publishing is working, and the latest green artifacts show the correct AutoHotkey v2 path. The remaining checked-in release blocker is now direct native Windows observation, not CI recovery.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so scheduler-query output and task-action audit evidence land in the same artifact.
    - Rerun in `-Mode Pass -ObservedBy "YourName"`, preserve the newest `logs\headless_release_gate_*.log`, and update `docs\headless_default_release_gate.md` from `PENDING_REAL_RUN` to `PASS`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:|OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal plus human desktop observation; cannot be closed from this WSL/OpenClaw session.

- [ ] **P1 — Add a hard CI guard that fails any future green run if `regression.log` shows the wrong AutoHotkey major version or loses the explicit v2 resolution line**
  - **Why this is second:** the two newest green artifacts look clean, but proof quality should live in the workflow itself rather than depend on one-off manual artifact inspection.
  - **Deliverables:**
    - Keep resolving an explicit AutoHotkey v2 executable before running regression.
    - Fail the workflow if `regression.log` contains `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
    - Fail the workflow if `regression.log` stops showing the resolved v2 executable line.
    - Publish one new successful run whose `regression.log` passes those assertions.
  - **Verification:**
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `python3 - <<'PY'
from pathlib import Path
p = next(Path('tmp/windows-regression-artifact').glob('**/regression.log'))
raw = p.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Resolved AutoHotkey v2 executable:' in text
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** requires workflow/source changes plus a fresh GitHub Actions run; cannot be closed in this docs-only pass.

- [ ] **P1 — Refresh `docs/status.md` and `docs/critical_todo.md` immediately after the next evidence-bearing change so operator docs stop advertising the stale failures/zero-artifacts story**
  - **Why this is third:** the current status docs now misstate repo state, but syncing them is lower leverage than closing the release gate and codifying the CI proof guard.
  - **Deliverables:**
    - Remove the stale `only failures` / `0 artifacts` framing.
    - Cite the fresh success runs (`23018180172`, `23014208204`) and the artifact contents they actually published.
    - Keep the docs explicit that green CI artifacts improve regression confidence but do **not** replace native Windows PASS evidence.
  - **Verification:**
    - `grep -n "only failure\|only failures\|0 artifacts\|zero stored Actions artifacts\|total_count.:0" docs/status.md docs/critical_todo.md`
    - `grep -n "23018180172\|23014208204\|regression.log\|workflow-context.txt" docs/status.md docs/critical_todo.md`
    - Manual diff review confirming native Windows PASS evidence still remains the checked-in release blocker.
  - **Current blocker:** none, but this should follow the next real evidence-bearing change so the status docs are refreshed once with stable wording.

## Notes

- **Priority ordering changed in this pass.**
- The earlier AutoHotkey v2 discovery repair is no longer the lead queue item because the two newest `windows-regression.yml` runs are green and publish full artifact bundles.
- The remaining gap is now primarily **release-proof closure** (native Windows PASS) plus **regression hardening** and **status-doc sync**.
- No source-code changes were made in this maintenance pass.
