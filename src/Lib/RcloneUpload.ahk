class RcloneUpload {
  static Upload(rcloneExe, archivePath, remote, retries := 3) {
    cmd := Shell.Quote(rcloneExe) . " copy " . Shell.Quote(archivePath) . " " . Shell.Quote(remote) . " --retries " . retries
    Logger.Info("Running rclone: " cmd)
    result := Shell.Exec(cmd, "", true)

    if (result.stdout != "")
      Logger.Info("rclone stdout: " Trim(result.stdout))
    if (result.stderr != "")
      Logger.Warn("rclone stderr: " Trim(result.stderr))

    Logger.Info("rclone exit code: " result.exitCode " durationMs=" result.durationMs " timedOut=" result.timedOut)
    return result
  }
}
