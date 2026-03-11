# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 18:44 UTC.

## Current evidence snapshot

- Repo status for this maintenance pass is **clean**: `git status --short --branch` returned only `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- `scripts/Regression.ps1` now exists and is already referenced by `README.md` as the canonical repo-local regression command.
- `scripts/Regression.ps1` currently runs:
  - `scripts/CheckHeadlessDefault.ps1`
  - `scripts/CheckPrereqs.ps1` against the checked-in pass/fail readiness fixtures
  - `scripts/SmokeTest.ps1` with a fixture-backed smoke config by default (`config\fixtures\readiness.pass.ini`)
- The biggest still-open engineering gaps visible from the repo are now:
  - no GitHub Actions workflow exists under `.github/workflows/`
  - `scripts/SmokeTest.ps1` still defaults to live/local `config\app.ini` when invoked directly
  - `scripts/VerifyNonInteractiveDefault.ps1` still duplicates `scripts/CheckHeadlessDefault.ps1`
  - `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`
  - `docs/status.md` and `docs/critical_todo.md` are still missing, while root `STATUS.md` is stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging
- Because the first unchecked item is what autopilot will execute, the queue should start with the highest-impact work that is still open and materially advances confidence.

## Prioritized open items

- [ ] **P0 — Add lightweight Windows CI around the now-existing regression entrypoint**
  - **Why now:** the repo finally has a canonical `scripts/Regression.ps1`, but nothing runs it automatically on branch changes. The highest leverage next step is turning that local regression surface into an always-on guardrail.
  - **Deliverables:**
    - Add a Windows workflow under `.github/workflows/`.
    - Ensure the workflow installs or resolves AutoHotkey v2 before invoking the regression suite.
    - Run `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1` in CI.
    - Keep the workflow repo-local and non-secret by using only checked-in fixture configs.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path .github\workflows\windows.yml"`
    - `powershell -NoProfile -Command "Get-Content .github\workflows\windows.yml | Select-String -Pattern 'windows-latest|Regression.ps1|AutoHotkey'"`
    - The workflow file clearly invokes `scripts\Regression.ps1` on a Windows runner.

- [ ] **P1 — Make direct smoke-test usage deterministic and safe by default**
  - **Why now:** regression is now fixture-backed, but `scripts/SmokeTest.ps1` still defaults to `config\app.ini`. That keeps the most obvious one-off smoke command tied to local machine state and possible live settings.
  - **Deliverables:**
    - Change `scripts/SmokeTest.ps1` so its default path is fixture-backed and dry-run safe, or require `config\app.ini` only via explicit opt-in.
    - Keep direct smoke usage aligned with the regression suite’s checked-in readiness fixtures.
    - Update README/examples so the default smoke path no longer implies personal config.
  - **Verification:**
    - `powershell -NoProfile -Command "Get-Content scripts\SmokeTest.ps1 | Select-String -Pattern 'config\\app.ini|config\\fixtures'"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1`
    - The no-argument smoke path is repo-local, repeatable, and dry-run only.

- [ ] **P1 — Collapse duplicate headless static guards onto one canonical script**
  - **Why now:** both `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` still exist. The latter adds naming drift without adding meaningful coverage.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical guard.
    - Delete `scripts/VerifyNonInteractiveDefault.ps1` or reduce it to a thin compatibility wrapper.
    - Update any remaining references so the repo points to one canonical headless-check name.
  - **Verification:**
    - `grep -RIn "VerifyNonInteractiveDefault" README.md STATUS.md USER_TODO.md docs scripts`
    - `grep -RIn "CheckHeadlessDefault" README.md STATUS.md USER_TODO.md docs scripts`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`

- [ ] **P1 — Close the headless-default release gate with native Windows PASS evidence**
  - **Why now:** the repo has the capture/assert scaffolding, but the release claim is still not proven by committed Windows evidence.
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

- [ ] **P2 — Canonicalize status docs now that regression exists and packaging is no longer the first story**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, and root `STATUS.md` still points readers at installer packaging before the real confidence gaps: CI coverage, smoke determinism, and native Windows headless proof.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so it reflects the current order of work.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'Regression|headless|CI|installer'"`

## Notes

- The biggest correction in this pass is **removing the now-false claim that `scripts/Regression.ps1` does not exist**.
- The queue now treats CI as the highest-leverage next step because the regression command is already present and fixture-backed.
- Native-Windows proof remains a release blocker, but it is not the first executable repo task from this session.
- This maintenance pass intentionally stayed within docs-only scope.