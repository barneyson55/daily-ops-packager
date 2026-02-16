# Architecture

## Overview
The app is a simple pipeline driven by an INI config:
1) Collect files modified today from `paths.watchDir` matching `patterns.extensions`.
2) Copy matches into a temp workspace, preserving relative paths.
3) Create a password-protected 7z archive (AES-256 header encryption).
4) Optionally verify the archive with `7z t`.
5) Upload the archive with rclone.
6) Optionally send an email notification.
7) Append a daily summary CSV report in `logs/summary_YYYYMMDD.csv`.
8) Log every important step to `logs/`.

## Key decisions
- **No source mutation:** The source tree is never modified; only copies are made.
- **Temp cleanup after success:** The temp workspace is deleted only after a successful upload.
- **Keep artifacts on failure:** If zipping or uploading fails, the temp folder and the archive (if created) are kept for inspection.
- **Secrets via environment:** Passwords are never stored in the repo; only env variable names appear in the INI.
- **Dry-run mode:** Collects and logs only; no temp copy, zip, or upload.

## Components
- `src/OneClickBackup.ahk` orchestrates the flow and handles CLI args.
- `src/Lib/Config.ahk` loads INI and expands environment variables.
- `src/Lib/Logger.ahk` writes daily logs.
- `src/Lib/Report.ahk` appends a daily CSV summary per run.
- `src/Lib/FileCollector.ahk` finds today's files and copies them to temp.
- `src/Lib/ZipPack.ahk` calls 7-Zip with AES-256 (`-mhe=on`) and optional verify.
- `src/Lib/RcloneUpload.ahk` runs `rclone copy` with retries.
- `src/Lib/Notify.ahk` calls `scripts/SendMail.ps1`.

## Data flow
`watchDir` -> `tmpDir` -> `outDir` -> `rclone remote`
