# Deep Research — daily-ops-packager

Updated: 2026-03-11 19:40 UTC
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
- `scripts/CheckHeadlessDefault.ps1`
- `scripts/VerifyNonInteractiveDefault.ps1`

## What changed since the previous research pass

### 1) Windows CI is no longer a missing capability
Evidence:
- `.github/workflows/windows-regression.yml` now exists.
- The workflow runs on `windows-latest`.
- It installs AutoHotkey and invokes `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`.

Consequence:
- The old top-level roadmap item claiming CI was still missing is now stale and should be removed from the active queue.
- Prioritization should move to the next gap that CI still does **not** cover.

### 2) Direct smoke usage is still the weakest high-visibility path
Evidence:
- `scripts/SmokeTest.ps1` still defaults to `config\app.ini`.
- README still advertises smoke usage with `scripts\SmokeTest.ps1 -Config config\app.ini`.
- This differs from the safer fixture-backed regression path.

Consequence:
- The most obvious one-off validation command still depends on machine-local/live config unless the caller overrides it.
- This is now the highest-impact unblocked engineering gap.

### 3) Automated coverage still misses the direct no-arg smoke contract
Evidence:
- CI runs `scripts\Regression.ps1`.
- The workflow file does not itself exercise `scripts\SmokeTest.ps1` with no arguments.
- The repo therefore lacks an automated proof that the direct smoke entrypoint stays fixture-backed and safe by default.

Consequence:
- After fixing `scripts/SmokeTest.ps1`, the repo still needs automated coverage that specifically guards that no-arg behavior.

### 4) Headless static validation is still duplicated
Evidence:
- `scripts/CheckHeadlessDefault.ps1` exists and is the stronger, more complete static guard.
- `scripts/VerifyNonInteractiveDefault.ps1` still exists and checks overlapping behavior.

Consequence:
- The repo still carries naming drift and duplicated maintenance surface for the same headless-default claim.

### 5) The headless-default release gate is still open and blocked on native Windows execution
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- The document still says final proof must be captured from a native Windows terminal because this WSL/OpenClaw session cannot launch the required Windows binaries.

Consequence:
- This remains a real release blocker.
- It should stay near the top of the roadmap, but not as the first autopilot item because it is blocked in the current environment.

### 6) Status-doc topology is still stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still says `Last triage: 2026-02-15 (UTC)` and still leads with installer packaging.

Consequence:
- The obvious status entrypoints still tell an outdated story about what matters next.

## Highest-impact roadmap from current evidence

1. Make `scripts/SmokeTest.ps1` deterministic and safe by default for direct no-arg usage.
2. Add automated regression/CI coverage for that direct no-arg smoke path.
3. Collapse duplicate headless static guards onto `scripts/CheckHeadlessDefault.ps1`.
4. Close the headless-default release gate with native Windows PASS evidence.
5. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md`.

## Explicitly removed from the active top queue

- “Add a Windows CI workflow” — already landed.
- Any queue wording that still says `.github/workflows/` is missing.

## Assumptions

- The checked-in readiness fixtures remain the intended non-secret baseline for local regression and CI.
- The direct smoke path should be safe enough for humans to run without accidentally touching live/personal config.
- The headless-default release claim should not be treated as closed until native Windows evidence is committed.
- This maintenance pass is docs-only, so missing status docs are recorded as roadmap work rather than created here.

## Unknowns for a future pass

- Should `scripts/SmokeTest.ps1` switch fully to fixture-backed defaults, or should it force explicit confirmation before using `config\app.ini`?
- Should the direct no-arg smoke check live inside `scripts/Regression.ps1`, the GitHub Actions workflow, or both?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or kept as a compatibility shim?
- After smoke determinism and native Windows proof are in place, is installer packaging still the next strategic milestone?

## Resulting prioritization change

This refresh changes the queue materially:

1. **Removed** the stale claim that Windows CI is still missing.
2. **Promoted** direct smoke determinism to the first executable repo task.
3. **Added** explicit automated coverage for the direct no-arg smoke contract as a separate top-tier item.
4. **Kept** native-Windows PASS evidence as a near-top blocker, but not first because it is blocked in this environment.
5. **Kept** status-doc canonicalization as cleanup after the remaining confidence gaps are better aligned.
