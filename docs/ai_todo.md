# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 19:40 UTC.

## Current evidence snapshot

- Repo status at the start of this maintenance pass was **clean**: `git status --short --branch` returned only `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- A Windows CI workflow now exists at `.github/workflows/windows-regression.yml` and already runs `scripts\Regression.ps1` on `windows-latest` after installing AutoHotkey.
- `scripts/Regression.ps1` exists and is the canonical repo-local regression entrypoint.
- The remaining top engineering gaps visible from current repo evidence are:
  - the workflow/regression path does **not** yet prove that direct no-arg smoke usage is fixture-backed and safe
  - `scripts/VerifyNonInteractiveDefault.ps1` still duplicates `scripts/CheckHeadlessDefault.ps1`
  - `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`
  - `docs/status.md` and `docs/critical_todo.md` are still missing while root `STATUS.md` remains stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging
- Because autopilot executes the first unchecked item, the queue should start with the highest-impact **unblocked** work rather than blocked native-Windows proof.

## Prioritized open items

- [x] **P0 — Make direct smoke-test usage deterministic and safe by default**
  - **Completed:** `scripts/SmokeTest.ps1` now defaults to `config\fixtures\readiness.pass.ini`, seeds repo-local fixture env vars for the no-arg path, and restores the caller environment afterward.
  - **Completed:** README/examples now advertise the fixture-backed no-arg smoke command and keep `config\app.ini` as explicit opt-in only.
  - **Verification attempted from this WSL/OpenClaw session:** static grep/diff only; native `powershell` is not installed here, so the Windows command still needs to be executed from a native Windows shell for runtime confirmation.

- [ ] **P1 — Add regression coverage for the direct no-arg smoke path**
  - **Why now:** once `scripts/SmokeTest.ps1` is made safe by default, that contract still needs an automated guard. The current workflow proves `scripts\Regression.ps1`, but not the direct no-arg smoke entrypoint humans will reach for.
  - **Deliverables:**
    - Extend `scripts/Regression.ps1`, CI, or both so the no-argument `scripts\SmokeTest.ps1` path is executed automatically.
    - Ensure the automated check fails if the default smoke path drifts back to `config\app.ini` or another machine-local config.
    - Keep the coverage repo-local and non-secret.
  - **Verification:**
    - `powershell -NoProfile -Command "Get-Content scripts\Regression.ps1,.github\workflows\windows-regression.yml | Select-String -Pattern 'SmokeTest\.ps1'"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
    - The automated regression surface visibly exercises `scripts\SmokeTest.ps1` without requiring `-Config config\app.ini`.

- [ ] **P1 — Collapse duplicate headless static guards onto one canonical script**
  - **Why now:** both `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` still exist. The second name adds drift without obvious extra coverage.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical guard.
    - Delete `scripts/VerifyNonInteractiveDefault.ps1` or reduce it to a thin compatibility wrapper.
    - Update remaining references so the repo points to one canonical headless-check name.
  - **Verification:**
    - `grep -RIn "VerifyNonInteractiveDefault" README.md STATUS.md USER_TODO.md docs scripts`
    - `grep -RIn "CheckHeadlessDefault" README.md STATUS.md USER_TODO.md docs scripts`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`

- [ ] **P1 — Close the headless-default release gate with native Windows PASS evidence**
  - **Why now:** the repo has CI, static guards, and evidence-capture scaffolding, but the release claim is still not proven by committed native-Windows observation.
  - **Deliverables:**
    - Run the safe capture from native Windows PowerShell.
    - Run the PASS-grade capture after directly observing that default runs stay headless unless `--interactive` is passed.
    - Refresh `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and optional scheduler proof.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this OpenClaw/WSL session cannot launch the native Windows binaries required for the final proof run.

- [ ] **P2 — Canonicalize status docs around current confidence gaps instead of installer packaging**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, and root `STATUS.md` still tells the old story. A reader can still miss that CI is in place and the real remaining gaps are smoke determinism, automated direct-smoke coverage, duplicate guard cleanup, and native Windows proof.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so it reflects the current order of work.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'Regression|headless|CI|installer|SmokeTest'"`

## Notes

- The biggest correction in this maintenance pass was **removing the now-false assumption that Windows CI is still missing**, then landing the next unblocked engineering fix on top of that updated picture.
- Direct no-arg smoke usage is now fixture-backed and explicit opt-in is required to exercise `config\app.ini`.
- Native-Windows PASS evidence remains a real release blocker, but it is intentionally not first because it cannot be completed from this WSL/OpenClaw session.
- The next executable repo task is adding automated regression coverage for the direct no-arg smoke path.
