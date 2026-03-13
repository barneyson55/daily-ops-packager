# Current Status

Last updated: 2026-03-13 10:01 UTC

This is the canonical repo status summary. It explains what the automated Windows regression proves, what still requires manual native-Windows evidence, and which follow-up items remain.

## Release story in one screen

- **Release blocker:** `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- **What CI already proves:** `.github/workflows/windows-regression.yml` runs `scripts\Regression.ps1` on `windows-latest`, which covers:
  - the static headless-default guard (`scripts\CheckHeadlessDefault.ps1`)
  - readiness/prereq checks against fixture configs (`scripts\CheckPrereqs.ps1`)
  - the safe default smoke path (`scripts\SmokeTest.ps1` with no `-Config`, which uses the repo-local readiness fixture)
- **What CI has now been rechecked to publish for reviewers:** successful run `23039582037` on `master` still exposes a downloadable artifact bundle containing:
  - `regression.log`
  - `regression-summary.md`
  - `workflow-context.txt`
- **What the rechecked artifact says:** `regression.log` still includes `Resolved AutoHotkey v2 executable:` and `Regression suite OK.`, and still does not include the old AutoHotkey v1 mismatch strings.
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

### 3. Live artifact verification has now been rechecked successfully

Fresh repo-root checks at **2026-03-13 08:26 UTC** show:

- `gh run list --workflow windows-regression.yml --limit 5` shows latest run `23039582037` completed with `success` on `master`, after earlier failures in the recent history.
- `gh api repos/barneyson55/daily-ops-packager/actions/runs/23039582037` confirms `conclusion: success`, `head_sha: 4ed16802a533c52f1d46870eba6b597a370cf782`, and run URL `https://github.com/barneyson55/daily-ops-packager/actions/runs/23039582037`.
- `gh run download 23039582037 --dir tmp/windows-regression-success` re-downloaded the retained artifact bundle.
- `gh api repos/barneyson55/daily-ops-packager/actions/runs/23039582037/artifacts` returns `total_count: 1` for `windows-regression-23039582037-1`.
- The downloaded bundle contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
- `regression.log` contains `Resolved AutoHotkey v2 executable:` and `Regression suite OK.`.
- `regression.log` does **not** contain `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.

So downloadable workflow artifacts are no longer a stale or hypothetical claim here: the latest sampled green run was rechecked from this repo root in this pass. That closes the earlier status-surface mismatch, but it does **not** close the native Windows PASS gate.

### 4. Smoke-command guidance is now quarantined correctly

Canonical docs now default to the safe no-argument smoke path and keep `-Config config\app.ini` as explicit opt-in for live/local testing.

The remaining dated planning-doc hit in `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` has been replaced with the safe default smoke command, so the old live-config smoke form is no longer presented there as copy-pasteable guidance.

## What to tell a reviewer today

If someone asks "are we release-ready?", the accurate answer is:

1. **Partially.** The repo has the Windows regression workflow definition, a freshly rechecked successful CI artifact bundle, and the headless-evidence capture tooling.
2. **Not fully proven yet.** The checked-in native Windows PASS artifact is still missing.
3. **Freshly rechecked CI confidence exists now,** but it is still not a substitute for native-desktop observation of the no-dialog claim.

## Next work in order

1. **Docs anti-drift cleanup:** keep `docs/status.md` canonical and trim the other status surfaces so they stop carrying independent histories.
2. **Manual/native Windows:** close `docs\headless_default_release_gate.md` with PASS evidence.
