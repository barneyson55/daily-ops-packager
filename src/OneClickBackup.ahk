#Requires AutoHotkey v2.0
#SingleInstance Force

#Include %A_ScriptDir%\Lib\Config.ahk
#Include %A_ScriptDir%\Lib\Logger.ahk
#Include %A_ScriptDir%\Lib\Shell.ahk
#Include %A_ScriptDir%\Lib\FileCollector.ahk
#Include %A_ScriptDir%\Lib\ZipPack.ahk
#Include %A_ScriptDir%\Lib\RcloneUpload.ahk
#Include %A_ScriptDir%\Lib\Notify.ahk
#Include %A_ScriptDir%\Lib\Report.ahk

main()

main() {
  baseDir := DirGetParent(A_ScriptDir)
  cfg := ""
  summary := { status: "unknown", fileCount: 0, archivePath: "", zipExit: "", verifyExit: "", uploadExit: "", message: "" }

  try {
    opts := ParseArgs(A_Args)
    configPath := opts.configPath != "" ? opts.configPath : "config\\app.sample.ini"
    configPath := Config.ResolvePath(Config.ExpandEnv(configPath), baseDir)

    Logger.Init(baseDir)
    Logger.Info("Starting OneClickBackup. config=" configPath " dryRun=" opts.dryRun)

    cfg := Config.Load(configPath, baseDir)

    ValidatePrereqs(cfg, opts.dryRun)

    files := FileCollector.Collect(cfg.paths.watchDir, cfg.patterns.extensions, cfg.paths.tmpDir, opts.dryRun, cfg.patterns.include, cfg.patterns.exclude)
    count := files.Length
    summary.fileCount := count
    Logger.Info("Files matched for today: " count)

    if (opts.dryRun) {
      summary.status := "dry-run"
      summary.message := "Dry-run"
      SafeWriteSummary(baseDir, summary)
      ConsoleWrite("Dry-run: " count " files would be archived.")
      MsgBox "Dry-run: " count " files would be archived."
      return
    }

    if (count = 0) {
      summary.status := "no-files"
      summary.message := "No files matched today."
      SafeWriteSummary(baseDir, summary)
      Logger.Warn("No files matched today. Nothing to do.")
      ConsoleWrite("No files matched today. Nothing to do.")
      MsgBox "No files matched today. Nothing to do."
      return
    }

    DirCreate(cfg.paths.outDir)
    archiveName := ZipPack.BuildArchiveName(cfg.zip.archiveName)
    archivePath := cfg.paths.outDir "\\" archiveName
    summary.archivePath := archivePath

    zipExit := ZipPack.CreateArchive(cfg.zip.exe, cfg.paths.tmpDir, archivePath, EnvGet(cfg.zip.passwordEnv))
    summary.zipExit := zipExit
    if (zipExit != 0)
      throw Error("7-Zip failed with exit code " zipExit)

    if (cfg.zip.verify) {
      verifyExit := ZipPack.VerifyArchive(cfg.zip.exe, archivePath, EnvGet(cfg.zip.passwordEnv))
      summary.verifyExit := verifyExit
      if (verifyExit != 0)
        throw Error("7-Zip verify failed with exit code " verifyExit)
    }

    uploadExit := RcloneUpload.Upload(cfg.rclone.exe, archivePath, cfg.rclone.remote, cfg.rclone.retries)
    summary.uploadExit := uploadExit
    if (uploadExit != 0)
      throw Error("rclone failed with exit code " uploadExit)

    try DirDelete(cfg.paths.tmpDir, true)
    catch as err2
      Logger.Warn("Failed to delete temp dir: " err2.Message)

    if (cfg.email.enabled) {
      Notify.Send(cfg.email, "Backup success", "Archive uploaded: " archivePath)
    }

    Logger.Info("Backup complete: " archivePath)
    summary.status := "success"
    summary.message := "OK"
    SafeWriteSummary(baseDir, summary)
    ConsoleWrite("Backup complete: " archivePath)
    MsgBox "Backup complete: " archivePath
  } catch as err {
    Logger.Error(err.Message)
    if (IsObject(cfg) && cfg.HasOwnProp("email") && cfg.email.enabled) {
      try Notify.Send(cfg.email, "Backup failed", err.Message)
    }
    summary.status := "failed"
    summary.message := err.Message
    SafeWriteSummary(baseDir, summary)
    ConsoleWrite("Error: " err.Message)
    MsgBox "Error: " err.Message
    ExitApp 1
  }
}

ParseArgs(args) {
  opts := { configPath: "", dryRun: false }
  i := 1
  while (i <= args.Length) {
    arg := args[i]
    if (arg = "--config" || arg = "-c") {
      if (i = args.Length)
        throw Error("Missing value for --config")
      opts.configPath := args[i + 1]
      i += 2
      continue
    }
    if (arg = "--dry-run") {
      opts.dryRun := true
      i += 1
      continue
    }
    if (arg = "--help" || arg = "-h") {
      ShowHelp()
      ExitApp 0
    }
    throw Error("Unknown argument: " arg)
  }
  return opts
}

ShowHelp() {
  msg := "OneClickBackup usage:`n"
  msg .= "  OneClickBackup.ahk --config config\\app.ini [--dry-run]`n"
  msg .= "Options:`n"
  msg .= "  --config, -c   Path to INI config`n"
  msg .= "  --dry-run      Collect and log only`n"
  msg .= "  --help, -h     Show help`n"
  MsgBox msg
}

ValidatePrereqs(cfg, dryRun := false) {
  if (cfg.paths.watchDir = "")
    throw Error("paths.watchDir is empty")
  if (!DirExist(cfg.paths.watchDir))
    throw Error("watchDir not found: " cfg.paths.watchDir)

  if (cfg.patterns.extensions = "")
    throw Error("patterns.extensions is empty")

  if (!dryRun) {
    if (cfg.paths.tmpDir = "")
      throw Error("paths.tmpDir is empty")
    if (cfg.paths.outDir = "")
      throw Error("paths.outDir is empty")

    if (cfg.zip.exe = "" || !FileExist(cfg.zip.exe))
      throw Error("7-Zip not found: " cfg.zip.exe)
    if (cfg.zip.passwordEnv = "")
      throw Error("zip.passwordEnv is empty")
    if (cfg.zip.archiveName = "")
      throw Error("zip.archiveName is empty")
    if (EnvGet(cfg.zip.passwordEnv) = "")
      throw Error("Missing zip password env: " cfg.zip.passwordEnv)

    if (cfg.rclone.exe = "" || !FileExist(cfg.rclone.exe))
      throw Error("rclone not found: " cfg.rclone.exe)
    if (cfg.rclone.remote = "")
      throw Error("rclone.remote is empty")

    if (cfg.email.enabled) {
      if (cfg.email.smtpHost = "")
        throw Error("email.smtpHost is empty")
      if (cfg.email.from = "" || cfg.email.to = "")
        throw Error("email.from or email.to is empty")
      if (cfg.email.user = "")
        throw Error("email.user is empty")
      if (cfg.email.passwordEnv = "")
        throw Error("email.passwordEnv is empty")
      if (EnvGet(cfg.email.passwordEnv) = "")
        throw Error("Missing SMTP password env: " cfg.email.passwordEnv)
    }
  }
}

ConsoleWrite(text) {
  try FileAppend(text "`n", "*")
}

SafeWriteSummary(baseDir, summary) {
  try Report.WriteDaily(baseDir, summary)
  catch as err
    Logger.Warn("Failed to write summary report: " err.Message)
}
