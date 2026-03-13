# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-13 02:14 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only maintenance pass: `## master...origin/master`.
- Fresh `gh run list --repo barneyson55/daily-ops-packager --workflow windows-regression.yml --limit 10` shows the workflow is **not** in the old `all failing / no artifacts` state, but it is also not healthy on current `master`:
  - `23031883329` — failure (latest)
  - `23029500849` — failure
  - `23018180172` — success
  - `23014208204` — success
  - `22997394546` — success
- `gh api repos/barneyson55/daily-ops-packager/actions/artifacts` currently reports `total_count: 12`, so artifact publishing is live.
- Downloaded artifact evidence for the latest failure `23031883329` proves the earlier **truthful pre-regression artifact** fix is now live:
  - artifact contains `pre-regression-failure.txt`, `regression-summary.md`, and `workflow-context.txt`
  - summary says `Outcome: skipped`, `Job status: failure`, and `Regression log present: False`
  - summary explicitly says the run failed before `scripts\Regression.ps1` produced `regression.log`
- GitHub Actions job metadata for `23031883329` shows the failure happens at **step 3: `Install AutoHotkey v2`**; both `Prepare regression artifact directory` and `Run regression suite` are skipped.
- Downloaded job logs for failed job `66891748015` show the exact current breakage:
  - Chocolatey installs `autohotkey.install v2.0.21`
  - the workflow resolves `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
  - then invokes the resolved executable as `AutoHotkey64.exe /ErrorStdOut /CP65001`
  - that probe fails with `AutoHotkey64.ahk (0) : ==> Script file not found.` and exits the job before regression starts
- Downloaded artifact evidence for success run `23018180172` still shows the happy path works when the install step does not fail:
  - artifact contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`
  - decoded `regression.log` contains `Resolved AutoHotkey v2 executable:` and `Regression suite OK.`
  - decoded `regression.log` does **not** contain `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`
- Local repo evidence shows why the queue needs to pivot again:
  - `.github/workflows/windows-regression.yml` already contains the new truthful skipped-run artifact logic
  - the same workflow file also contains the newly added bare-executable probe that matches the latest failure mode
  - `git diff d7e987f 7739502 -- .github/workflows/windows-regression.yml` shows both changes landed together
- Architecture evidence still points to a small, high-leverage release surface:
  - one AHK entrypoint: `src/OneClickBackup.ahk`
  - PowerShell validation/evidence harness around it: `scripts/Regression.ps1`, `scripts/SmokeTest.ps1`, `scripts/CheckPrereqs.ps1`, `scripts/RunHeadlessEvidenceCapture.ps1`, `scripts/CaptureHeadlessEvidence.ps1`
  - release confidence still depends on both CI regression evidence **and** a native Windows PASS artifact
- `scripts/VerifyNonInteractiveDefault.ps1` is only a thin wrapper around `scripts/CheckHeadlessDefault.ps1`, and `rg` shows the repo/docs already point directly to `CheckHeadlessDefault.ps1`; the duplicate guard surface is still low-level cleanup, not the lead blocker.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the native Windows release proof is still missing.
- `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` are stale because they still describe the older `only failures / zero artifacts` picture and do not mention the newer split reality: truthful skipped-run artifacts are now fixed, but current `master` fails earlier in the AutoHotkey install/probe step.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Do **not** leave a native-Windows-only or human-observation-only task in slot 1 while an agent-actionable repo task is still open.
- Every item must end with a clear verification block that can pass or fail.
- Keep blocked external work visible, but mark the blocker explicitly.

## Prioritized open items

- [ ] **P0 — Fix the AutoHotkey install-step probe so `windows-regression.yml` stops failing before regression starts**
  - **Why this is first:** the previous top gap (truthful skipped-run artifacts) is now fixed and proven by run `23031883329`. The new highest-impact issue is that current `master` fails in step 3 before `scripts\Regression.ps1` can run at all.
  - **Evidence:** failed job log `66891748015` shows the newly added probe invokes `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe /ErrorStdOut /CP65001` and gets `AutoHotkey64.ahk (0) : ==> Script file not found.`
  - **Deliverables:**
    - Change `.github/workflows/windows-regression.yml` so `Install AutoHotkey v2` verifies the resolved runtime **without** invoking the interpreter in a way that requires an implicit script file.
    - Keep the protection against accidentally accepting AutoHotkey v1.
    - Preserve the already-good truthful skipped-run artifact behavior when regression never starts.
    - Prefer a deterministic probe contract (for example: file-version/path validation only, or an explicit helper script passed to the interpreter) rather than a bare-executable invocation.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh api repos/barneyson55/daily-ops-packager/actions/runs/<new-run>/jobs`
    - Confirm step `Install AutoHotkey v2` concludes `success`.
    - `gh api repos/barneyson55/daily-ops-packager/actions/jobs/<job-id>/logs > tmp/windows-regression-job.log`
    - `! grep -n "Script file not found\|AutoHotkey64\.ahk \(0\) : ==> Script file not found" tmp/windows-regression-job.log`
    - If the run still fails later, it must fail **after** the install step and after the regression artifact directory is prepared.
  - **Current blocker:** none.

- [ ] **P1 — Re-establish one fresh green `windows-regression.yml` run on current `master` and re-verify the full artifact bundle**
  - **Why this is second:** once P0 is fixed, the next highest-value outcome is a new green run proving the happy path still works with the revised runtime validation.
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

- [ ] **P2 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is third:** this is still the checked-in release blocker, but it is not continuously actionable from this WSL/OpenClaw session and should stay behind the agent-actionable CI repair work.
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

- [ ] **P3 — Collapse the duplicate static-guard surface so `CheckHeadlessDefault.ps1` is the only canonical entrypoint**
  - **Why this is fourth:** repo evidence shows `VerifyNonInteractiveDefault.ps1` is now only a wrapper and all meaningful call sites already reference `CheckHeadlessDefault.ps1`. Cleaning this up reduces surface area and makes future evidence/docs drift less likely.
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

- [ ] **P4 — Refresh `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` after P0/P1 so operator docs match the real current state**
  - **Why this is fifth:** the docs are currently stale, but the higher-leverage work is fixing the live CI break first so the refreshed status pages do not immediately go stale again.
  - **Deliverables:**
    - Remove the outdated `only failures` / `0 artifacts` framing.
    - Record that truthful skipped-run artifacts are now proven by failed run `23031883329`.
    - Record that current `master` still fails earlier in `Install AutoHotkey v2` because of the new bare-executable probe.
    - Preserve the distinction between CI regression confidence and the still-open native Windows PASS gate.
  - **Verification:**
    - `grep -n "only failure\|only failures\|0 artifacts\|zero stored Actions artifacts\|total_count.:0" STATUS.md docs/status.md docs/critical_todo.md`
    - `grep -n "23031883329\|23018180172\|pre-regression-failure.txt\|Script file not found\|Install AutoHotkey v2\|total_count: 12" STATUS.md docs/status.md docs/critical_todo.md`
    - Manual diff review confirms native Windows PASS evidence remains the checked-in release blocker until P2 closes.
  - **Current blocker:** best done after P0/P1 so the docs can reference one fresh post-fix run.

## Notes

- The main queue shift in this pass is real: **truthful skipped-run artifacts are no longer the lead gap** because the latest failed artifact already proves that fix landed.
- The new lead issue is **the install-step AutoHotkey runtime probe itself**, which currently causes a false failure before regression can begin.
- The repo remains a small Windows automation pipeline with one AHK app plus PowerShell verification/evidence wrappers; that keeps the highest-impact roadmap concentrated in a few scripts and one workflow file.
- No source-code changes were made in this maintenance pass; this file was reprioritized from repo + CI evidence only.
