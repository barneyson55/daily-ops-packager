# Deep Research — daily-ops-packager

Updated: 2026-03-11 22:00 UTC
Scope of this pass: local repo evidence only, docs-only maintenance pass, no source-code changes.

## Sources reviewed

### Local repo evidence
- `git status --short --branch`
- `STATUS.md`
- `README.md`
- `docs/ai_todo.md` (pre-refresh)
- `docs/deep_research_auto.md` (pre-refresh)
- `docs/headless_default_release_gate.md`
- existence checks for `docs/status.md` and `docs/critical_todo.md`
- `.github/workflows/windows-regression.yml`
- `scripts/SmokeTest.ps1`
- `scripts/Regression.ps1`
- `scripts/CheckHeadlessDefault.ps1`
- `scripts/VerifyNonInteractiveDefault.ps1`
- `scripts/CaptureHeadlessEvidence.ps1`
- `scripts/RunHeadlessEvidenceCapture.ps1`
- `scripts/AssertHeadlessReleaseGate.ps1`

## What changed since the previous research pass

### 1) The previous top-priority gap is now closed: regression already proves the literal no-arg smoke command
Evidence:
- `.github/workflows/windows-regression.yml` runs `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1` on `windows-latest`.
- `scripts/Regression.ps1` now contains a `Dry-run smoke path (literal no-arg default)` step.
- That step invokes `scripts\SmokeTest.ps1` without a `-Config` override and asserts both:
  - `Using repo-local readiness fixture: config\fixtures\readiness.pass.ini`
  - `Smoke test OK.`

Consequence:
- The old P0 about adding automated coverage for the literal no-argument smoke entrypoint is no longer actionable.
- Keeping it at the top of `docs/ai_todo.md` would now mislead future maintenance passes.

### 2) The headless evidence-capture path is now the biggest safety/alignment gap
Evidence:
- `scripts/CaptureHeadlessEvidence.ps1` still defaults `-Config` to `config\app.ini`.
- `scripts/RunHeadlessEvidenceCapture.ps1` also still defaults `-Config` to `config\app.ini`.
- The capture flow still records the smoke step as `powershell ... -File scripts\SmokeTest.ps1 -Config config\app.ini`.
- README describes `scripts\RunHeadlessEvidenceCapture.ps1` as a safe default, no-real-run capture flow.

Consequence:
- The highest-risk human-facing proof flow is still biased toward live/local config even though the repo's safer smoke default is now fixture-backed and regression-proven.
- The next most important task is to align capture tooling and docs with that safe-first contract.

### 3) Headless static validation is still duplicated
Evidence:
- `scripts/CheckHeadlessDefault.ps1` exists and is the stronger guard.
- `scripts/VerifyNonInteractiveDefault.ps1` still exists and checks overlapping behavior.

Consequence:
- The repo still carries duplicate maintenance surface and naming drift around the same headless-default claim.

### 4) The headless release gate is still open, and one of its command surfaces is stale
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- The document still lists `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini` as a verification command.
- Native Windows PASS evidence is still not checked in.

Consequence:
- Native Windows PASS evidence remains a real release blocker.
- The release-gate workflow itself should be aligned to the safe smoke default before or alongside the final Windows proof pass.

### 5) Status-doc topology is still stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still says `Last triage: 2026-02-15 (UTC)` and still leads with installer packaging.
- At least one dated planning doc still references `scripts\SmokeTest.ps1 -Config config\app.ini` as if it were normal guidance.

Consequence:
- A reader can still get the wrong picture of what matters next unless they inspect several files manually.
- Status and doc-topology cleanup remains worthwhile, but it should sit below the safety/alignment fixes above.

## Highest-impact roadmap from current evidence

1. Make `RunHeadlessEvidenceCapture` / `CaptureHeadlessEvidence` use the safe fixture-backed smoke path by default.
2. Collapse duplicate headless static guards onto `scripts\CheckHeadlessDefault.ps1`.
3. Close the headless-default release gate with native Windows PASS evidence.
4. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md`.
5. Sweep stale docs so only explicit opt-in or clearly historical contexts mention `scripts\SmokeTest.ps1 -Config config\app.ini`.

## Explicitly removed from the active top queue

- The completed item for adding automated coverage of the literal no-argument `scripts\SmokeTest.ps1` path.

## Assumptions

- The checked-in readiness fixtures remain the intended non-secret baseline for local regression and CI.
- The direct smoke path should stay safe enough for humans to run without accidentally touching live/personal config.
- The headless evidence-capture flow should honor that same safe-first principle unless the operator explicitly opts into a live-config proof run.
- The headless-default release claim should not be treated as closed until native Windows evidence is committed.
- This maintenance pass is docs-only, so missing status docs are recorded as roadmap work rather than created here.

## Unknowns for a future pass

- Should the evidence-capture scripts default all smoke proof to the literal no-arg `SmokeTest.ps1` entrypoint, or should they pass `config\fixtures\readiness.pass.ini` explicitly while preserving identical behavior?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or kept as a compatibility shim?
- After the capture-path alignment is fixed, should README keep calling the wrapper's safe mode "safe default" or be more explicit about which parts still inspect `config\app.ini`?
- Should old planning docs be updated in place, or should they be labeled as archived/historical to avoid accidental misuse?
- After smoke/capture alignment and native Windows proof are in place, is installer packaging still the next strategic milestone?

## Resulting prioritization change

This refresh changes the queue in four concrete ways:

1. **Removed** the stale top item about adding automated proof of the literal no-arg smoke command, because that proof is now already in `scripts/Regression.ps1` and CI.
2. **Promoted** safe-default alignment of the headless evidence-capture flow to the top actionable engineering task.
3. **Kept** native-Windows PASS evidence near the top, but below the capture-alignment work because the current WSL/OpenClaw environment still cannot complete that proof.
4. **Retained** status/doc cleanup as important but secondary work behind the safety- and release-confidence gaps.