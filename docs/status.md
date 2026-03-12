# Current Status

Last updated: 2026-03-12 (UTC)

This is the canonical repo status summary. It explains what the automated Windows regression proves, what still requires manual native-Windows evidence, and which follow-up items remain.

## Release story in one screen

- **Release blocker:** `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- **What CI already proves:** `.github/workflows/windows-regression.yml` runs `scripts\Regression.ps1` on `windows-latest`, which covers:
  - the static headless-default guard (`scripts\CheckHeadlessDefault.ps1`)
  - readiness/prereq checks against fixture configs (`scripts\CheckPrereqs.ps1`)
  - the safe default smoke path (`scripts\SmokeTest.ps1` with no `-Config`, which uses the repo-local readiness fixture)
- **What CI does not yet prove:**
  - direct observation on a native Windows desktop that the default path stays headless unless `--interactive` is passed
  - PASS-grade durable evidence in `docs\headless_default_release_gate.md`
  - local scheduled-task action audit and optional observed scheduled-task headless behavior for `OneClickBackupDaily`
- **Current review-surface gap:** the Windows regression workflow is still console-only; it does not yet publish durable downloadable artifacts for reviewers.

## Evidence surfaces

- `STATUS.md` — short repo-root summary for quick triage
- `docs/status.md` — this canonical status explanation
- `docs/critical_todo.md` — only the current real blockers
- `docs/headless_default_release_gate.md` — durable native-Windows headless gate artifact
- `.github/workflows/windows-regression.yml` — automated Windows regression entrypoint
- `scripts\Regression.ps1` — regression suite currently executed by GitHub Actions

## Current state

### 1. Native Windows PASS evidence is still the release blocker

The repo has the capture/assert tooling needed to collect the evidence:

- `scripts\RunHeadlessEvidenceCapture.ps1`
- `scripts\CaptureHeadlessEvidence.ps1`
- `scripts\AssertHeadlessReleaseGate.ps1`

What is still missing is the actual **native Windows PASS run** that updates `docs\headless_default_release_gate.md` from `PENDING_REAL_RUN` to `PASS` with observer attribution, plus scheduler proof when applicable.

### 2. Automated Windows regression exists and is useful

GitHub Actions already runs the repo's Windows regression suite on `push`, `pull_request`, and `workflow_dispatch`.

That automated path is useful for catching drift in:

- headless-default script wiring
- fixture-backed prereq validation
- safe smoke-command behavior

It should be treated as **regression confidence**, not as final release proof for the no-dialog claim.

### 3. Durable workflow artifacts are still missing

Reviewers currently get pass/fail console logs from the workflow run, but no durable artifact bundle to link from docs or release notes.

That is the next best unblocked engineering follow-up after the status-doc cleanup.

### 4. Smoke-command guidance is mostly corrected

Canonical docs now default to the safe no-argument smoke path and keep `-Config config\app.ini` as explicit opt-in for live/local testing.

At least one dated planning document still contains the older copy-pasteable live-config smoke command, so a cleanup sweep is still queued.

## What to tell a reviewer today

If someone asks "are we release-ready?", the accurate answer is:

1. **Partially.** The repo has automated Windows regression and the headless-evidence capture tooling.
2. **Not fully proven yet.** The checked-in native Windows PASS artifact is still missing.
3. **So the current blocker is evidence, not missing capture code.**

## Next work in order

1. **Manual/native Windows:** close `docs\headless_default_release_gate.md` with PASS evidence.
2. **Unblocked automation/docs:** make `.github/workflows/windows-regression.yml` publish durable review artifacts.
3. **Cleanup:** remove or clearly mark stale `scripts\SmokeTest.ps1 -Config config\app.ini` guidance outside explicit opt-in or historical contexts.
