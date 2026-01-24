class Config {
  static Load(path, baseDir) {
    if (!FileExist(path))
      throw Error("Config file not found: " path)

    cfg := {}
    cfg.paths := {}
    cfg.patterns := {}
    cfg.zip := {}
    cfg.rclone := {}
    cfg.email := {}

    cfg.paths.watchDir := this.ResolvePath(this.ExpandEnv(IniRead(path, "paths", "watchDir", "")), baseDir)
    cfg.paths.outDir := this.ResolvePath(this.ExpandEnv(IniRead(path, "paths", "outDir", "out")), baseDir)
    cfg.paths.tmpDir := this.ResolvePath(this.ExpandEnv(IniRead(path, "paths", "tmpDir", "")), baseDir)

    cfg.patterns.extensions := Trim(IniRead(path, "patterns", "extensions", ""))

    cfg.zip.exe := this.ResolvePath(this.ExpandEnv(IniRead(path, "zip", "exe", "")), baseDir)
    cfg.zip.passwordEnv := Trim(IniRead(path, "zip", "passwordEnv", ""))
    cfg.zip.archiveName := Trim(IniRead(path, "zip", "archiveName", ""))

    cfg.rclone.exe := this.ResolvePath(this.ExpandEnv(IniRead(path, "rclone", "exe", "")), baseDir)
    cfg.rclone.remote := Trim(IniRead(path, "rclone", "remote", ""))
    cfg.rclone.retries := Integer(IniRead(path, "rclone", "retries", "3"))

    cfg.email.enabled := Integer(IniRead(path, "email", "enabled", "0"))
    cfg.email.smtpHost := Trim(IniRead(path, "email", "smtpHost", ""))
    cfg.email.smtpPort := Integer(IniRead(path, "email", "smtpPort", "587"))
    cfg.email.useSsl := Integer(IniRead(path, "email", "useSsl", "1"))
    cfg.email.from := Trim(IniRead(path, "email", "from", ""))
    cfg.email.to := Trim(IniRead(path, "email", "to", ""))
    cfg.email.user := Trim(IniRead(path, "email", "user", ""))
    cfg.email.passwordEnv := Trim(IniRead(path, "email", "passwordEnv", ""))

    return cfg
  }

  static ExpandEnv(val) {
    if (val = "")
      return val
    replacer := (m) => (EnvGet(m[1]) != "") ? EnvGet(m[1]) : m[0]
    return RegExReplace(val, "%([^%]+)%", replacer)
  }

  static ResolvePath(path, baseDir) {
    if (path = "")
      return path
    if (this.IsAbsolute(path))
      return path
    return baseDir "\\" path
  }

  static IsAbsolute(path) {
    if (RegExMatch(path, "i)^[A-Z]:\\"))
      return true
    if (SubStr(path, 1, 2) = "\\")
      return true
    return false
  }
}
