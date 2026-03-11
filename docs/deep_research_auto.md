# Deep Research — daily-ops-packager

Updated: 2026-03-11 23:10 UTC
Scope of this pass: local repo evidence only, docs-only maintenance pass, no source-code changes.

## Sources reviewed

### Local repo evidence
- `git status --short --branch`
- `git ls-files`
- `STATUS.md`
- `README.md`
- `docs/ai_todo.md` (pre-refresh)
- `docs/deep_research_auto.md` (pre-refresh)
- `docs/headless_default_release_gate.md`
- existence checks for `docs/status.md` and `docs/critical_todo.md`
- repo-wide reference scans for:
  - `CheckHeadlessDefault`
  - `VerifyNonInteractiveDefault`
  - `SmokeTest.ps1`
  - `SmokeTest.ps1 -Config config\app.ini`
  - `PENDING_REAL_RUN`
  - `installer`

## What changed since the previous research pass

### 1) The safe-first evidence-capture/doc alignment item is no longer open
Evidence:
- `README.md` now presents `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1` as the primary safe smoke/default path.
- `docs/headless_default_release_gate.md` does the same, while keeping `-Config config\app.ini` explicitly labeled as opt-in/local evidence.
- The release-gate doc also states that the evidence-capture script now defaults to the repo-local readiness fixture-backed smoke path.

Consequence:
- The old top queue item about making evidence capture use the safe fixture-backed smoke path by default is stale.
- Keeping that completed item at the top would make `docs/ai_todo.md` less actionable.

### 2) Native Windows PASS evidence is now the highest-impact remaining blocker
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- The same doc says checked-in Windows proof is still missing.
- The required verification surface already exists: wrapper capture commands plus `scripts\AssertHeadlessReleaseGate.ps1`.

Consequence:
- The queue should now lead with the native Windows PASS capture, even though this WSL/OpenClaw session cannot complete it directly.
- This is the most important unresolved proof gap in the repo.

### 3) Status-doc topology is still stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still says `Last triage: 2026-02-15 (UTC)` and still leads with installer packaging as the first top-level task.

Consequence:
- The repo still lacks one current, canonical status story.
- This is the biggest documentation gap after the Windows proof blocker.

### 4) Stale smoke-command guidance still exists outside the canonical docs
Evidence:
- `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` still references `scripts\SmokeTest.ps1 -Config config\app.ini`.
- Canonical docs now treat that command as deliberate opt-in, not the default recommendation.

Consequence:
- There is still some risk that a reader copy-pastes a live/local command from an older planning doc.
- A doc sweep is still warranted even though the main docs are already fixed.

### 5) Duplicate headless-guard code still exists, but canonical references are already mostly converged
Evidence:
- `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` are both present in the repo.
- Current repo-facing references found in `README.md`, `docs/headless_default_release_gate.md`, `scripts/Regression.ps1`, and `scripts/CaptureHeadlessEvidence.ps1` point to `CheckHeadlessDefault.ps1`.
- `VerifyNonInteractiveDefault.ps1` is currently discussed in research/todo docs, but not promoted as the active canonical entrypoint.

Consequence:
- Duplicate-guard cleanup still matters, but it sits below the release-gate and status-doc issues.
- The cleanup is now more about reducing drift than fixing user-facing guidance.

## Highest-impact roadmap from current evidence

1. Close the headless-default release gate with native Windows PASS evidence.
2. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md` around the real blockers.
3. Sweep stale smoke-command guidance so only explicit opt-in or clearly historical contexts mention `scripts\SmokeTest.ps1 -Config config\app.ini`.
4. Remove or shim `scripts\VerifyNonInteractiveDefault.ps1` so one static guard is truly canonical.

## Explicitly removed from the active top queue

- The completed item for making evidence capture use the safe fixture-backed smoke path by default.

## Assumptions

- The repo-local readiness fixtures remain the intended non-secret baseline for smoke/regression coverage.
- The no-argument `scripts\SmokeTest.ps1` path should remain the human-safe default in canonical docs.
- The headless-default release claim should not be treated as closed until native Windows evidence is checked in.
- Missing `docs/status.md` and `docs/critical_todo.md` are roadmap work, not path-discovery work.

## Unknowns for a future pass

- After Windows PASS evidence is captured, should installer packaging still be the next strategic milestone, or should reliability/documentation cleanup remain ahead of packaging?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or preserved as a compatibility wrapper?
- Should older dated planning docs be updated in place, or labeled more explicitly as archived/historical?

## Resulting prioritization change

This refresh changes the queue in four concrete ways:

1. **Removed** the now-completed safe-first evidence-capture alignment item from the active queue.
2. **Promoted** native Windows PASS evidence to the top priority because it is the strongest remaining release-confidence blocker.
3. **Promoted** status-doc canonicalization above duplicate-guard cleanup because readers still lack a single accurate status surface.
4. **Kept** the stale-doc sweep and duplicate-guard cleanup as important follow-on work, but below the proof and status-story gaps.
