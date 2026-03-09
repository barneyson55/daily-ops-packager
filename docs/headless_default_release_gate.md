# Headless Default Release Gate (Windows evidence)

- Status: **PENDING_REAL_RUN**
- Purpose: durable proof surface for the `P0 — Close the headless-default release gate with real Windows evidence` item.

## What is still required

- Run the default non-interactive path on a real Windows machine for both:
  - dry-run / smoke path
  - real default run
- Confirm by direct observation that no blocking `MsgBox` appears unless `--interactive` is passed.
- Confirm the scheduled/manual default path also stays headless.

## Verification commands

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`
- `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless`

## Current repo state

- Static headless guard exists: `scripts\CheckHeadlessDefault.ps1`
- Durable evidence capture entrypoint exists: `scripts\CaptureHeadlessEvidence.ps1`
- Checked-in Windows proof is still missing; this gate is not closed yet.

## Next action

Run `scripts\CaptureHeadlessEvidence.ps1` on Windows after reviewing the target config and only use `-IncludeRealRun` when a real upload/email-capable run is safe.
