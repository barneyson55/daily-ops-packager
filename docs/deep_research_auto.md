# Deep Research — daily-ops-packager

Updated: 2026-03-11 17:52 UTC
Scope of this pass: local repo evidence only, docs-only maintenance pass, no source-code changes.

## Sources reviewed

### Local repo evidence
- `git status --short --branch`
- `STATUS.md`
- `README.md`
- `USER_TODO.md`
- `docs/ai_todo.md` (pre-refresh)
- `docs/deep_research_auto.md` (pre-refresh)
- `docs/headless_default_release_gate.md`
- existence checks for `docs/status.md` and `docs/critical_todo.md`
- existence checks for `.github/workflows/*`, `scripts/Regression.ps1`, `config/readiness.contract.ini`, and `config/fixtures/*`
- `src/OneClickBackup.ahk`
- `scripts/CheckPrereqs.ps1`
- `scripts/SmokeTest.ps1`
- `scripts/CheckHeadlessDefault.ps1`
- `scripts/VerifyNonInteractiveDefault.ps1`
- `scripts/RunHeadlessEvidenceCapture.ps1`
- `scripts/AssertHeadlessReleaseGate.ps1`
- `config/readiness.contract.ini`
- `config/fixtures/readiness.pass.ini`
- `config/fixtures/readiness.fail-watchdir.ini`
- `config/fixtures/readiness.fail-email.ini`

## What changed since the previous research pass

### 1) The readiness-validation blocker previously at the top of the queue is now already resolved
Evidence:
- `src/OneClickBackup.ahk` now calls `Readiness.Validate(cfg, contractPath, dryRun)` from `ValidatePrereqs(...)`.
- `scripts/CheckPrereqs.ps1` now reads the same `config\readiness.contract.ini` file.
- `config/fixtures/` now exists and includes:
  - `readiness.pass.ini`
  - `readiness.fail-watchdir.ini`
  - `readiness.fail-email.ini`
  - stubbed `bin/7z.exe`, `bin/rclone.exe`, and empty `watch/`, `tmp/`, `out/` directories

Consequence:
- The prior `docs/ai_todo.md` / `docs/deep_research_auto.md` emphasis on readiness-contract unification and fixture creation is stale.
- Those items should be removed from the active top queue.

### 2) The repo is still clean in this maintenance pass
Evidence:
- `git status --short --branch` returned only `## master...origin/master`.

Consequence:
- Current prioritization should focus on open engineering gaps, not workspace cleanup.

## Highest-impact findings from current repo evidence

### 1) There is still no canonical regression command
Evidence:
- `scripts/Regression.ps1` does not exist.
- `.github/workflows/*` does not exist.
- The repo now has enough building blocks to support a clean local regression surface:
  - `scripts/CheckHeadlessDefault.ps1`
  - `scripts/CheckPrereqs.ps1`
  - `config/readiness.contract.ini`
  - `config/fixtures/*`
  - `scripts/SmokeTest.ps1`

Implication:
- The repo still lacks one obvious “run this before shipping” command.

Roadmap consequence:
- This should be the first executable queue item.

### 2) The smoke path is still less deterministic than the new readiness-fixture path
Evidence:
- `scripts/SmokeTest.ps1` defaults to `config\app.ini`.
- `scripts/SmokeTest.ps1` also looks up `AutoHotkey64.exe` / `AutoHotkey.exe` from PATH unless `-AhkExe` is provided.
- In contrast, the readiness path already has checked-in deterministic configs under `config/fixtures/*`.

Implication:
- The most obvious smoke command still depends on local machine state and possibly live configuration, which weakens repeatability for autopilot and future CI.

Roadmap consequence:
- Either make smoke testing fixture-backed by default or require live `config\app.ini` only as an explicit opt-in.

### 3) Headless static validation is still duplicated
Evidence:
- `scripts/CheckHeadlessDefault.ps1` exists and is referenced by README, `USER_TODO.md`, and the evidence-capture flow.
- `scripts/VerifyNonInteractiveDefault.ps1` also exists.
- Repo-wide references found only the planning docs mentioning `VerifyNonInteractiveDefault.ps1`.

Implication:
- The duplicate script is a drift risk and adds naming confusion without adding clear coverage.

Roadmap consequence:
- Collapse onto `scripts/CheckHeadlessDefault.ps1` as the canonical guard.

### 4) The headless-default release gate is still open, but now mainly blocked on native Windows execution
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- `scripts/RunHeadlessEvidenceCapture.ps1` exists and enforces `-ObservedBy` in `-Mode Pass`.
- `scripts/AssertHeadlessReleaseGate.ps1` exists and verifies PASS-grade metadata in the doc.

Implication:
- The release-gate problem is no longer missing scaffolding; it is missing final real-Windows evidence.

Roadmap consequence:
- Keep this in the top tier, but below repo-local work that can be completed directly from source control.

### 5) Release-state docs are still fragmented and partially stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still says `Last triage: 2026-02-15 (UTC)` and still leads with installer packaging.

Implication:
- A human or agent reading only the obvious status files can still be pointed at the wrong next step.

Roadmap consequence:
- Fix status-doc topology after the regression surface and headless proof are in better shape.

## Recommended roadmap order

### Now / highest leverage
1. Add `scripts/Regression.ps1` as the canonical local regression entrypoint.
2. Make the smoke path deterministic and safe by default.
3. Collapse duplicate headless static guards onto one canonical script.
4. Close the headless-default release gate with native Windows evidence.
5. Add a lightweight Windows CI wrapper around `scripts/Regression.ps1`.
6. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md`.

## Explicitly removed from the active top queue

- Readiness-contract unification: already landed.
- Readiness fixtures: already landed.
- Any prioritization that assumes `scripts/CheckPrereqs.ps1` and runtime validation still drift by default.

## Assumptions

- The checked-in readiness contract is the intended source of truth for prereq validation.
- The main distribution target is still a Windows user running AutoHotkey + PowerShell + rclone locally or via Task Scheduler.
- The headless-default release claim should not be treated as closed until native Windows evidence is committed.
- This maintenance pass is docs-only, so missing docs are recorded as roadmap gaps rather than created here.

## Unknowns for a future pass

- What is the safest fixture-backed config shape for a deterministic smoke run that still exercises meaningful end-to-end behavior?
- Should the eventual CI job run only repo-local fixture checks, or should it also exercise a dry-run AHK path on Windows runners?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or kept as a compatibility shim?
- After regression confidence is in place, is installer packaging still the next strategic milestone, or does log/report ergonomics need another pass first?

## Resulting prioritization change

This refresh changes the queue materially:

1. **Removed** the stale readiness-unification blocker from the top queue.
2. **Removed** the stale fixture-creation blocker from the top queue.
3. **Promoted** the missing canonical regression command to the first executable item.
4. **Promoted** deterministic smoke-path work because smoke still defaults to live `config\app.ini`.
5. **Kept** the native-Windows evidence task in the top tier, but below unblocked repo-local work.
6. **Kept** status-doc canonicalization as cleanup after confidence-building work, not as a substitute for it.