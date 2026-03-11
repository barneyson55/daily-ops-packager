# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 23:10 UTC.

## Current evidence snapshot

- Repo status at the start of this maintenance pass was **clean**: `git status --short --branch` returned `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- `README.md` and `docs/headless_default_release_gate.md` both now make the literal no-argument `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1` path the primary safe smoke/default run, while keeping `-Config config\app.ini` as explicit opt-in for local/live evidence.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so final release confidence still depends on checked-in native Windows PASS evidence.
- `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` still both exist, but repo-facing command references now point to `scripts/CheckHeadlessDefault.ps1` as the canonical guard.
- Root `STATUS.md` is still stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging instead of the current release-confidence gaps.
- At least one dated planning doc still advertises the old smoke command (`docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` references `scripts\SmokeTest.ps1 -Config config\app.ini`), so stale guidance is still present outside the canonical docs.

## Prioritized open items

- [ ] **P0 — Close the headless-default release gate with native Windows PASS evidence**
  - **Why now:** this is still the highest-impact blocker to shipping confidence. The repo already has the guard, the smoke path, the evidence-capture wrapper, and the PASS assert; what is missing is the actual observed Windows proof.
  - **Deliverables:**
    - Run the safe native Windows capture from a real Windows terminal.
    - Run the PASS-grade capture after directly observing that the default path stays headless unless `--interactive` is passed.
    - If `OneClickBackupDaily` exists, include scheduler proof in the same PASS-grade artifact.
    - Update `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and scheduler proof when applicable.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this WSL/OpenClaw session still cannot launch the native Windows binaries needed for the final proof run.

- [ ] **P1 — Canonicalize status docs around current confidence gaps instead of installer packaging**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, while root `STATUS.md` leads with an outdated first task. A reader still has to triangulate several files to understand what matters.
  - **Deliverables:**
    - Add `docs/status.md` with current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so it matches the actual order of work: native Windows PASS evidence first, then the next unblocked cleanup items.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'headless|SmokeTest|Regression|CI|installer'"`
    - Human review confirms all three status surfaces tell the same story.

- [ ] **P1 — Sweep stale smoke-command guidance so only explicit opt-in or historical contexts mention `-Config config\app.ini`**
  - **Why now:** the repo's canonical docs are now safe-first, but at least one dated planning doc still presents the old live-config smoke command in a way that can be copy-pasted as current guidance.
  - **Deliverables:**
    - Update current guidance docs so the no-argument smoke path is the default recommendation everywhere canonical.
    - For dated planning docs, either remove stale command guidance or label it clearly as historical/non-canonical.
    - Keep `-Config config\app.ini` examples only where live/local config use is the deliberate point.
  - **Verification:**
    - `rg -n "SmokeTest\\.ps1" README.md STATUS.md docs`
    - `rg -n "SmokeTest\\.ps1 -Config config\\app\\.ini" README.md STATUS.md docs`
    - Human review confirms every remaining `-Config config\app.ini` example is clearly opt-in or historical.

- [ ] **P2 — Remove or shim the duplicate headless static guard so one script is truly canonical**
  - **Why now:** references have effectively converged on `scripts/CheckHeadlessDefault.ps1`, but `scripts/VerifyNonInteractiveDefault.ps1` still exists as overlapping maintenance surface and can drift silently.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical guard.
    - Delete `scripts/VerifyNonInteractiveDefault.ps1` or reduce it to a thin compatibility wrapper that calls the canonical script.
    - Update any remaining repo references if new ones are found.
  - **Verification:**
    - `rg -n "VerifyNonInteractiveDefault|CheckHeadlessDefault" README.md STATUS.md docs scripts .github`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - If a wrapper is kept: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\VerifyNonInteractiveDefault.ps1`

## Notes

- The previously checked item for making evidence capture use the safe fixture-backed smoke path by default was removed from the active queue because the repo docs and wrapper flow are already aligned on that behavior.
- Native Windows PASS evidence is now the top priority because it is the strongest remaining release-confidence blocker.
- Missing `docs/status.md` and `docs/critical_todo.md` are tracked as real doc work, not as path-discovery problems.
