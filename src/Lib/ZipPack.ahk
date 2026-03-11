class ZipPack {
  static BuildArchiveName(template) {
    name := StrReplace(template, "{YYYYMMDD}", FormatTime(, "yyyyMMdd"))
    name := StrReplace(name, "{HHmm}", FormatTime(, "HHmm"))
    return name
  }

  static CreateArchive(zipExe, tmpDir, archivePath, password) {
    if (!DirExist(tmpDir))
      throw Error("Temp directory not found: " tmpDir)

    passArg := "-p" . Shell.Quote(password)
    cmd := Shell.Quote(zipExe) . " a -t7z -mhe=on " . passArg . " " . Shell.Quote(archivePath) . " ."
    logCmd := Shell.Quote(zipExe) . " a -t7z -mhe=on -p""***"" " . Shell.Quote(archivePath) . " ."

    Logger.Info("Running 7-Zip: " logCmd)
    result := Shell.Exec(cmd, tmpDir, true)

    if (result.stdout != "")
      Logger.Info("7-Zip stdout: " Trim(result.stdout))
    if (result.stderr != "")
      Logger.Warn("7-Zip stderr: " Trim(result.stderr))

    Logger.Info("7-Zip exit code: " result.exitCode " durationMs=" result.durationMs " timedOut=" result.timedOut)
    return result
  }

  static VerifyArchive(zipExe, archivePath, password) {
    passArg := "-p" . Shell.Quote(password)
    cmd := Shell.Quote(zipExe) . " t " . passArg . " " . Shell.Quote(archivePath)
    logCmd := Shell.Quote(zipExe) . " t -p""***"" " . Shell.Quote(archivePath)

    Logger.Info("Verifying archive: " logCmd)
    result := Shell.Exec(cmd, "", true)

    if (result.stdout != "")
      Logger.Info("7-Zip verify stdout: " Trim(result.stdout))
    if (result.stderr != "")
      Logger.Warn("7-Zip verify stderr: " Trim(result.stderr))

    Logger.Info("7-Zip verify exit code: " result.exitCode " durationMs=" result.durationMs " timedOut=" result.timedOut)
    return result
  }
}
