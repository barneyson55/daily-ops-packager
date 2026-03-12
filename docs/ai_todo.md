# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 17:46 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only maintenance pass: `## master...origin/master`.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the checked-in native Windows release proof is still missing.
- `docs/status.md` and `docs/critical_todo.md` are older than the latest AI-maintained evidence and still describe the earlier `only failures` / `0 artifacts` state.
- The most recent evidence-rich AI docs still point to the same operational story:
  - last successful `windows-regression.yml` run: `22997394546`
  - newer failed runs after that: `23006791388`, `23010206186`
  - newest failure still shows installed v2 paths such as `C:\Program Files\AutoHotkey\v2\AutoHotkey.exe` and `AutoHotkey64.exe`, then throws `AutoHotkey v2 executable not found after Chocolatey install.`
  - the last green `regression.log` still contains wrong-runtime strings (`This script requires AutoHotkey v2.0.` and `Current interpreter: AutoHotkey v1...`) before ending with `Regression suite OK.`
- Consequence: the highest-impact sequence is still **repair CI discovery first, then prove the repaired green run is actually using AutoHotkey v2, then close the native Windows release gate, then sync stale status docs**.

## Queueing rule for this file

- Keep only 3-7 concrete open items.
- Order by engineering leverage, not by easiest docs edit.
- Every item must end with a clear verification block that can pass or fail.
- Treat stale doc sync as a trailing task unless it changes operator decisions right now.

## Prioritized open items

- [ ] **P0 — Repair AutoHotkey v2 discovery in `windows-regression.yml` so the workflow reaches `scripts\Regression.ps1` again**
  - **Why this is first:** the newest runs fail before the regression suite can produce fresh evidence, so there is nothing current to trust until discovery/install selection is fixed.
  - **Deliverables:**
    - Accept the actual installed v2 executable paths already shown in runner logs (`C:\Program Files\AutoHotkey\v2\AutoHotkey.exe` and/or `AutoHotkey64.exe`).
    - Stop failing with `AutoHotkey v2 executable not found after Chocolatey install.` when those paths exist.
    - Publish one new successful `windows-regression.yml` run whose artifact bundle includes `regression.log`.
  - **Verification:**
    - `gh run view <new-success-run> --log-failed`
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `find tmp/windows-regression-artifact -name regression.log -print | grep regression.log`
  - **Current blocker:** requires workflow/source changes plus a fresh GitHub Actions run; cannot be closed in this docs-only pass.

- [ ] **P0 — Make the repaired workflow fail fast on wrong AutoHotkey major-version output, then prove one clean green artifact**
  - **Why this stays second:** the last green run is not trustworthy enough because it still logged AutoHotkey v1 / `requires v2.0` strings before reporting success.
  - **Deliverables:**
    - Run the smoke/regression path through an explicit AutoHotkey v2 executable.
    - Make the workflow fail if `regression.log` contains either `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
    - Publish one successful run whose `regression.log` contains `Regression suite OK.` and none of the wrong-runtime strings.
  - **Verification:**
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `python3 - <<'PY'
from pathlib import Path
p = next(Path('tmp/windows-regression-artifact').glob('**/regression.log'))
raw = p.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** depends on the discovery repair above and a fresh successful run; cannot be closed in this docs-only pass.

- [ ] **P0 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this remains top-tier:** even trustworthy CI does not replace the checked-in release proof that the default path stays headless on a real Windows desktop unless `--interactive` is passed.
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

- [ ] **P1 — Refresh `docs/status.md` and `docs/critical_todo.md` immediately after the next evidence-bearing CI or native-Windows change**
  - **Why this is last:** the docs are stale, but syncing them before the next real evidence update would create unnecessary churn and likely require another rewrite.
  - **Deliverables:**
    - Remove the stale `only failures` / `0 artifacts` framing.
    - Record the run ids and timestamps used for the refresh.
    - Keep the docs explicit that green CI artifacts improve regression confidence but do **not** replace the native Windows PASS gate.
  - **Verification:**
    - `grep -n "only failure\|only failures\|zero stored artifacts\|total_count.:0" docs/status.md docs/critical_todo.md docs/ai_todo.md`
    - Manual diff review confirming the refreshed docs still name native Windows PASS evidence as the remaining checked-in release blocker.
  - **Current blocker:** none, but this should follow the next real evidence update so the status docs change once instead of repeatedly.

## Notes

- The priority ordering did **not** change in this pass; the evidence still supports the same sequence of work.
- What changed is the wording discipline: the queue is now more explicit that item 1 restores fresh evidence generation, item 2 prevents false-positive greens, item 3 closes the real release gate, and item 4 is deliberate trailing doc sync.
- No source-code changes were made in this maintenance pass.
