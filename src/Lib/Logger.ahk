class Logger {
  static logDir := ""
  static logFile := ""

  static Init(baseDir) {
    this.logDir := baseDir "\\logs"
    DirCreate(this.logDir)
    date := FormatTime(, "yyyyMMdd")
    this.logFile := this.logDir "\\backup_" date ".log"
  }

  static Info(msg) {
    this._Write("INFO", msg)
  }

  static Warn(msg) {
    this._Write("WARN", msg)
  }

  static Error(msg) {
    this._Write("ERROR", msg)
  }

  static _Write(level, msg) {
    if (this.logFile = "")
      return
    ts := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    line := ts " [" level "] " msg "`n"
    FileAppend(line, this.logFile)
    try FileAppend(line, "*")
  }
}
