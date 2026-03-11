# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 17:52 UTC.

## Current evidence snapshot

- Repo status for this maintenance pass is **clean**: `git status --short --branch` returned only `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- Root `STATUS.md` is still stale for roadmap guidance: `Last triage: 2026-02-15 (UTC)` and its first top-level task is still installer packaging.
- The previous top blocker in this file is now **closed by repo evidence**:
  - `src/OneClickBackup.ahk` now delegates `ValidatePrereqs(...)` to `config\readiness.contract.ini`
  - `scripts/CheckPrereqs.ps1` reads the same `config\readiness.contract.ini`
  - `config/fixtures/` now exists with deterministic pass/fail configs and stubbed `bin/`, `watch/`, `tmp/`, and `out/` assets
- The biggest still-open engineering gaps visible from the repo are now:
  - no canonical `scripts/Regression.ps1` exists
  - no `.github/workflows/*` entrypoint exists
  - `scripts/SmokeTest.ps1` still defaults to live `config\app.ini`, making the most obvious smoke path less deterministic than the new readiness-fixture path
  - `scripts/VerifyNonInteractiveDefault.ps1` still duplicates `scripts/CheckHeadlessDefault.ps1`, while the latter is the only script referenced by README and evidence-capture flow
  - `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**` and requires native Windows execution
- Because the first unchecked item is what autopilot will execute, the queue should start with the highest-impact repo work that is **still open and unblocked here**.

## Prioritized open items

- [ ] **P0 — Add one canonical regression command that exercises the repo-local confidence surface**
  - **Why now:** the repo now has the right building blocks (`readiness.contract.ini`, fixtures, headless guard, smoke script), but still lacks one command that says “this branch is basically healthy.”
  - **Deliverables:**
    - Add `scripts/Regression.ps1` as the canonical local regression entrypoint.
    - Make it run the static headless guard.
    - Make it run readiness pass/fail assertions using `config\fixtures\readiness.pass.ini`, `config\fixtures\readiness.fail-watchdir.ini`, and `config\fixtures\readiness.fail-email.ini`.
    - Include one dry-run smoke path with an explicit safe config, not an implicit dependency on a personal `config\app.ini`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
    - `powershell -NoProfile -Command "Get-Content scripts\Regression.ps1 | Select-String -Pattern 'CheckHeadlessDefault|CheckPrereqs|SmokeTest|readiness.pass|readiness.fail'"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.pass.ini`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.fail-watchdir.ini`

- [ ] **P1 — Make the smoke path deterministic and safe by default**
  - **Why now:** `scripts/SmokeTest.ps1` exists, but its default `-Config config\app.ini` still points at a live/local config, which weakens reproducibility and makes it a poor default for autopilot or future CI.
  - **Deliverables:**
    - Add or document a fixture-backed smoke config/path that is safe for repeated dry-runs.
    - Make the default smoke invocation explicitly deterministic, or require `config\app.ini` to be passed only when the operator intends to exercise a real local setup.
    - Ensure the smoke path does not depend on personal secrets unless the caller explicitly opts into the live config.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config <safe-fixture-or-sample-config>`
    - `powershell -NoProfile -Command "Get-Content scripts\SmokeTest.ps1 | Select-String -Pattern 'config\\app.ini|AhkExe|dry-run'"`
    - The documented default smoke path is repo-local, repeatable, and dry-run only.

- [ ] **P1 — Collapse duplicate headless static guards onto one canonical script**
  - **Why now:** both `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` still exist, but README and the evidence-capture flow only point to `CheckHeadlessDefault.ps1`. Keeping both invites drift.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical static guard.
    - Either delete `scripts/VerifyNonInteractiveDefault.ps1` or turn it into a thin wrapper that simply calls the canonical script.
    - Ensure docs and scripts reference only the canonical name.
  - **Verification:**
    - `grep -RIn "VerifyNonInteractiveDefault" .`
    - `grep -RIn "CheckHeadlessDefault" README.md USER_TODO.md docs scripts`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`

- [ ] **P1 — Close the headless-default release gate with native Windows evidence**
  - **Why now:** the tooling is in place (`RunHeadlessEvidenceCapture.ps1`, `AssertHeadlessReleaseGate.ps1`), but the checked-in release gate is still open because the final proof run has not been captured from native Windows.
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

- [ ] **P2 — Add lightweight Windows CI only after the local regression command exists**
  - **Why now:** `.github/workflows/*` is still absent. CI would be useful, but only after the repo has one clean local regression surface worth automating.
  - **Deliverables:**
    - Add a Windows workflow that invokes `scripts\Regression.ps1`.
    - Keep CI limited to repo-local, non-secret checks unless explicitly opted into live environment coverage.
    - Publish the workflow path in README or status docs.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path .github\workflows\windows.yml"`
    - `powershell -NoProfile -Command "Get-Content .github\workflows\windows.yml | Select-String -Pattern 'Regression.ps1|windows'"`

- [ ] **P2 — Canonicalize release-state docs after regression and headless proof are in place**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, while root `STATUS.md` still points readers at installer packaging before regression confidence and headless proof are closed.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so regression confidence and headless-proof work appear ahead of packaging.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'regression|headless|installer'"`

## Notes

- The biggest correction in this pass is **removing an already-landed item from the top of the queue**: readiness-contract unification and fixture creation are no longer open blockers.
- The new top item is the missing canonical regression command, because it is the highest-impact repo-local gap still open.
- Native-Windows evidence remains a top-tier release blocker, but not the first executable task in this session.
- This maintenance pass intentionally stayed within docs-only scope.