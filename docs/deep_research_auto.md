# Deep Research — daily-ops-packager

Updated: 2026-03-11 20:39 UTC
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

## What changed since the previous research pass

### 1) The safest smoke default landed, but the literal no-arg contract is still under-guarded
Evidence:
- `scripts/SmokeTest.ps1` now defaults to `config\fixtures\readiness.pass.ini`.
- The script seeds repo-local `READINESS_*` fixture env vars when using that default.
- The script restores the caller environment afterward.

Consequence:
- The repo is safer for humans who run the direct smoke command.
- The next gap is no longer the script default itself; it is automated proof that the literal no-argument path stays safe over time.

### 2) Windows CI exists, but it still does not prove the literal no-arg smoke path
Evidence:
- `.github/workflows/windows-regression.yml` exists and runs on `windows-latest`.
- The workflow invokes `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`.
- `scripts/Regression.ps1` still calls `scripts\SmokeTest.ps1` with an explicit `-Config` argument rather than exercising the literal no-arg entrypoint.

Consequence:
- CI proves the regression suite and fixture-backed smoke behavior in general.
- CI does **not** yet guard the exact human-facing contract: `powershell ... -File scripts\SmokeTest.ps1` with no extra flags.

### 3) Headless static validation is still duplicated
Evidence:
- `scripts/CheckHeadlessDefault.ps1` exists and covers the stronger static guard set.
- `scripts/VerifyNonInteractiveDefault.ps1` still exists and checks overlapping behavior.

Consequence:
- The repo still carries duplicate maintenance surface and naming drift around the same headless-default claim.

### 4) The headless release gate is still open and one of its own instructions is now stale
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- The document still tells the reader to run `scripts\SmokeTest.ps1 -Config config\app.ini` as part of verification.
- README now documents the safer no-arg smoke default instead.

Consequence:
- Native Windows PASS evidence remains a real release blocker.
- The release-gate doc itself now needs a follow-up doc sweep so it does not point users toward the more dangerous live-config path by default.

### 5) Status-doc topology is still stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still says `Last triage: 2026-02-15 (UTC)` and still leads with installer packaging.

Consequence:
- A reader can still get the wrong picture of what matters next unless they inspect several files manually.

## Highest-impact roadmap from current evidence

1. Add automated regression/CI coverage for the literal no-argument `scripts\SmokeTest.ps1` path.
2. Collapse duplicate headless static guards onto `scripts\CheckHeadlessDefault.ps1`.
3. Close the headless-default release gate with native Windows PASS evidence.
4. Sweep repo docs so smoke-test and headless-proof instructions match the new safe default.
5. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md`.

## Explicitly removed from the active top queue

- The completed work item for making `scripts/SmokeTest.ps1` safe by default.
- Any stale claim that Windows CI is still missing.

## Assumptions

- The checked-in readiness fixtures remain the intended non-secret baseline for local regression and CI.
- The direct smoke path should stay safe enough for humans to run without accidentally touching live/personal config.
- The headless-default release claim should not be treated as closed until native Windows evidence is committed.
- This maintenance pass is docs-only, so missing status docs are recorded as roadmap work rather than created here.

## Unknowns for a future pass

- Should the literal no-arg smoke check live inside `scripts/Regression.ps1`, the GitHub Actions workflow, or both?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or kept as a compatibility shim?
- Should the release-gate doc continue to mention `-Config config\app.ini` at all, or only as an explicit opt-in after the safe no-arg path?
- After smoke-contract coverage and native Windows proof are in place, is installer packaging still the next strategic milestone?

## Resulting prioritization change

This refresh changes the queue in four concrete ways:

1. **Removed** the completed smoke-default hardening item from the active queue.
2. **Promoted** automated proof of the literal no-arg smoke command to the top executable repo task.
3. **Added** an explicit docs-alignment task because the headless release-gate doc still points users at `config\app.ini` by default.
4. **Kept** native-Windows PASS evidence near the top, but below the highest-impact unblocked automation work because the current WSL/OpenClaw environment still cannot complete that proof.