# Config Reference

This document describes every INI field.

## [paths]
- `watchDir` (required): Source directory to scan for files modified today.
- `outDir` (required): Output directory for the generated .7z archive. Relative paths are resolved from the project root.
- `tmpDir` (required): Temporary workspace for copied files. `%TEMP%` is supported.

## [patterns]
- `extensions` (required): Semicolon-separated list of file patterns (e.g., `*.pdf;*.xlsx`). `*` or `*.*` matches all.

## [zip]
- `exe` (required): Full path to `7z.exe`.
- `passwordEnv` (required): Environment variable name for the archive password.
- `archiveName` (required): Filename template. Supports `{YYYYMMDD}` and `{HHmm}`.

## [rclone]
- `exe` (required): Full path to `rclone.exe`.
- `remote` (required): rclone destination, e.g., `myremote:backups/daily`.
- `retries` (optional): Retry count for upload (default 3).

## [email]
- `enabled` (optional): `1` to enable email notifications, `0` to disable.
- `smtpHost` (required when enabled): SMTP server.
- `smtpPort` (required when enabled): SMTP port.
- `useSsl` (required when enabled): `1` for SSL/TLS.
- `from` (required when enabled): From address.
- `to` (required when enabled): Recipient address.
- `user` (required when enabled): SMTP username.
- `passwordEnv` (required when enabled): Environment variable name for the SMTP password.
