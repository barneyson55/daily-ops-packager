# Current Status

Last updated: 2026-03-12 (UTC)

This is the canonical repo status summary. It explains what the automated Windows regression proves, what still requires manual native-Windows evidence, and which follow-up items remain.

## Release story in one screen

- **Release blocker:** `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- **What CI already proves:** `.github/workflows/windows-regression.yml` runs `scripts\Regression.ps1` on `windows-latest`, which covers:
  - the static headless-default guard (`scripts\CheckHeadlessDefault.ps1`)
  - readiness/prereq checks against fixture configs (`scripts\CheckPrereqs.ps1`)
  - the safe default smoke path (`scripts\SmokeTest.ps1` with no `-Config`, which uses the repo-local readiness fixture)
- **What CI now publishes for reviewers:** every workflow run uploads a durable artifact bundle with:
  - `regression.log`
  - `regression-summary.md`
  - `workflow-context.txt`
- **What CI still does not prove:**
  - direct observation on a native Windows desktop that the default path stays headless unless `--interactive` is passed
  - PASS-grade durable evidence in `docs\headless_default_release_gate.md`
  - local scheduled-task action audit and optional observed scheduled-task headless behavior for `OneClickBackupDaily`

## Evidence surfaces

- `STATUS.md` — short repo-root summary for quick triage
- `docs/status.md` — this canonical status explanation
- `docs/critical_todo.md` — only the current real blockers
- `docs/headless_default_release_gate.md` — durable native-Windows headless gate artifact
- `.github/workflows/windows-regression.yml` — automated Windows regression entrypoint and artifact publisher
- `scripts\Regression.ps1` — regression suite executed by GitHub Actions

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

### 3. Downloadable workflow artifacts now exist

Reviewers no longer need to rely only on console logs from the workflow UI.

Each Windows regression run now uploads a downloadable artifact bundle containing:

- `regression.log` — the captured workflow-side regression transcript
- `regression-summary.md` — a durable scope statement for what the CI run proves and what it does not prove
- `workflow-context.txt` — run metadata that helps reviewers tie the artifact bundle to a specific workflow execution

This improves reviewability and release-note linking, but it does **not** replace the native Windows PASS gate.

### 4. Smoke-command guidance is mostly corrected

Canonical docs now default to the safe no-argument smoke path and keep `-Config config\app.ini` as explicit opt-in for live/local testing.

At least one dated planning document still contains the older copy-pasteable live-config smoke command, so a cleanup sweep is still queued.

## What to tell a reviewer today

If someone asks "are we release-ready?", the accurate answer is:

1. **Partially.** The repo has automated Windows regression, downloadable CI artifact bundles, and the headless-evidence capture tooling.
2. **Not fully proven yet.** The checked-in native Windows PASS artifact is still missing.
3. **So the current blocker is native evidence, not missing workflow artifacting.**

## Next work in order

1. **Manual/native Windows:** close `docs\headless_default_release_gate.md` with PASS evidence.
2. **Unblocked engineering cleanup:** collapse the duplicate static guard surface so `scripts\CheckHeadlessDefault.ps1` is the only canonical guard.
3. **Docs cleanup:** remove or clearly mark stale `scripts\SmokeTest.ps1 -Config config\app.ini` guidance outside explicit opt-in or historical contexts.
