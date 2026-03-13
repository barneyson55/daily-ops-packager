# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-13 06:00 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only maintenance pass: `## master...origin/master`.
- Repo status docs are still split:
  - `docs/status.md`, `docs/critical_todo.md`, and repo-root `STATUS.md` still describe the older `only failures / zero artifacts` picture.
  - `docs/ai_todo.md` and `docs/deep_research_auto.md` already reflect the newer evidence that artifact publishing works again, but current `master` still fails earlier in `Install AutoHotkey v2`.
- Fresh GitHub evidence from this pass keeps the same lead engineering problem in place:
  - recent workflow results for `windows-regression.yml` are still mixed, with latest runs `23037310780`, `23034501857`, `23031883329`, and `23029500849` failing, while `23018180172` remains a recent success
  - artifact publishing is still live (`total_count: 13`)
  - newest failed run `23037310780` uploads a truthful skipped-run artifact bundle even though regression never starts
  - newest failed job `66908179368` again stops in `Install AutoHotkey v2`; `Prepare regression artifact directory` and `Run regression suite` are skipped
  - prior failed job `66891748015` captured the current probe break explicitly: `AutoHotkey64.exe /ErrorStdOut /CP65001` -> `AutoHotkey64.ahk (0) : ==> Script file not found.`
  - success run `23018180172` still proves the happy path can complete when the install step does not fail
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the native Windows PASS artifact remains the checked-in release blocker.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Do **not** leave a native-Windows-only or human-observation-only task in slot 1 while an agent-actionable repo task is still open.
- Keep blocked external work visible, but place it behind agent-actionable repo work when the impact is otherwise comparable.
- Every item must end with a clear verification block that can pass or fail.

## Prioritized open items

- [ ] **P0 — Fix the AutoHotkey install-step probe so `windows-regression.yml` reaches regression again**
  - **Why this is first:** the previous lead gap (truthful skipped-run artifacts) is already fixed and proven. The highest-impact active failure is now the install-step probe itself, which stops the workflow before `scripts\Regression.ps1` starts.
  - **Evidence:** newest failed run `23037310780` and prior failed run `23031883329` both stop at `Install AutoHotkey v2`. Failed job log `66891748015` shows the workflow resolves `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`, then invokes `AutoHotkey64.exe /ErrorStdOut /CP65001`, which fails with `AutoHotkey64.ahk (0) : ==> Script file not found.`
  - **Deliverables:**
    - Update `.github/workflows/windows-regression.yml` so `Install AutoHotkey v2` validates the resolved runtime **without** relying on a bare interpreter invocation that implies a missing script.
    - Preserve the guard against accidentally accepting AutoHotkey v1.
    - Preserve the already-good truthful skipped-run artifact behavior for cases where regression never starts.
    - Prefer a deterministic validation contract: file-version/path validation only, or an explicit helper script passed to the interpreter.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh api repos/barneyson55/daily-ops-packager/actions/runs/<new-run>/jobs`
    - Confirm step `Install AutoHotkey v2` concludes `success`.
    - `gh api repos/barneyson55/daily-ops-packager/actions/jobs/<job-id>/logs > tmp/windows-regression-job.log`
    - `! grep -n "Script file not found\|AutoHotkey64\.ahk \(0\) : ==> Script file not found" tmp/windows-regression-job.log`
    - If the run still fails later, it must fail **after** the install step and after the regression artifact directory is prepared.
  - **Current blocker:** none.

- [ ] **P1 — Re-establish one fresh green `windows-regression.yml` run on current `master` and re-verify the success artifact bundle**
  - **Why this is second:** once P0 is fixed, the next highest-value proof is a fresh green run showing the happy path still works with the revised runtime validation.
  - **Deliverables:**
    - Publish one new successful `windows-regression.yml` run after the P0 fix.
    - Keep the success-path artifact bundle complete: `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - Keep the runtime evidence in `regression.log`: `Resolved AutoHotkey v2 executable:` must be present, and the v1 mismatch text must remain absent.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh run download <new-success-run> --dir tmp/windows-regression-success`
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
  - **Current blocker:** depends on P0 plus one fresh successful Actions run.

- [ ] **P2 — Refresh `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` once P0/P1 land so operator docs match reality again**
  - **Why this is third:** the operator-facing status surfaces are stale right now. After P0/P1, refreshing them has higher near-term value than blocked native-Windows work because it restores truthful release communication across the repo and stays actionable from the repo side.
  - **Deliverables:**
    - Remove the outdated `only failures` / `0 artifacts` framing.
    - Record that truthful skipped-run artifacts are already proven by failed runs `23031883329` and `23037310780`.
    - Record the AutoHotkey install-step probe break and then replace it with the post-fix, post-green-run state once P0/P1 are complete.
    - Preserve the distinction between CI regression confidence and the still-open native Windows PASS gate until P3 closes.
  - **Verification:**
    - `grep -n "only failure\|only failures\|0 artifacts\|zero stored Actions artifacts\|total_count.:0" STATUS.md docs/status.md docs/critical_todo.md`
    - `grep -n "23037310780\|23031883329\|23018180172\|pre-regression-failure.txt\|Install AutoHotkey v2\|Script file not found" STATUS.md docs/status.md docs/critical_todo.md`
    - Manual diff review confirms the docs no longer claim the obsolete `all failures / zero artifacts` state.
    - Manual diff review confirms native Windows PASS evidence remains the checked-in release blocker until P3 closes.
  - **Current blocker:** best done after P0/P1 so the docs can point to one fresh post-fix run instead of another transient state.

- [ ] **P3 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is fourth:** this remains the checked-in release blocker, but it is not continuously actionable from this WSL/OpenClaw session and should stay behind the agent-actionable CI repair and status-sync work.
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

- [ ] **P4 — Collapse the duplicate static-guard surface so `CheckHeadlessDefault.ps1` is the only canonical entrypoint**
  - **Why this is fifth:** repo evidence still shows `VerifyNonInteractiveDefault.ps1` is only a thin wrapper. Cleaning it up would reduce naming drift, but it is lower leverage than repairing CI, restoring green evidence, and refreshing status docs.
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

## Notes

- The queue stays intentionally short: one live CI repair, one fresh proof run, one actionable status-sync task, one still-open native Windows release gate, then one cleanup item.
- The main ordering change in this pass is deliberate: **status-doc refresh now moves ahead of the native-Windows PASS gate** because the queue should remain actionable from the repo side after CI repair, while the PASS gate still depends on a native Windows terminal plus human observation.
- No source-code changes were made in this maintenance pass; this file was refreshed from repo + docs + live GitHub evidence only.
