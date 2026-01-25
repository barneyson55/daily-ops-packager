class FileCollector {
  static Collect(watchDir, extensions, tmpDir, dryRun := false, include := "", exclude := "") {
    if (!DirExist(watchDir))
      throw Error("watchDir not found: " watchDir)

    today := FormatTime(, "yyyyMMdd")
    extInfo := this.ParseExtensions(extensions)
    includePatterns := this.ParseWildcards(include)
    excludePatterns := this.ParseWildcards(exclude)
    files := []

    root := this.NormalizeDir(watchDir)
    Loop Files, root "\\*", "FR" {
      if (SubStr(A_LoopFileTimeModified, 1, 8) != today)
        continue
      SplitPath A_LoopFileFullPath, , , &ext
      if (!this.ExtAllowed(ext, extInfo))
        continue
      rel := this.RelPath(A_LoopFileFullPath, root)
      if (!this.IncludeAllowed(rel, includePatterns))
        continue
      if (this.ExcludeBlocked(rel, excludePatterns))
        continue
      files.Push(A_LoopFileFullPath)
      if (!dryRun) {
        dest := tmpDir "\\" rel
        SplitPath dest, , &destDir
        DirCreate(destDir)
        FileCopy A_LoopFileFullPath, dest, 1
      }
    }

    return files
  }

  static ParseExtensions(list) {
    extSet := Map()
    allowAll := false
    for _, item in StrSplit(list, ";") {
      t := Trim(item)
      if (t = "")
        continue
      if (t = "*" || t = "*.*") {
        allowAll := true
        continue
      }
      t := RegExReplace(t, "i)^\\*\\.", "")
      t := RegExReplace(t, "i)^\\.", "")
      if (t = "")
        continue
      extSet[StrLower(t)] := true
    }
    return { allowAll: allowAll, set: extSet }
  }

  static ExtAllowed(ext, extInfo) {
    if (extInfo.allowAll)
      return true
    return extInfo.set.Has(StrLower(ext))
  }

  static ParseWildcards(list) {
    patterns := []
    for _, item in StrSplit(list, ";") {
      t := Trim(item)
      if (t = "")
        continue
      t := StrReplace(t, "/", "\")
      patterns.Push(this.WildcardToRegex(t))
    }
    return patterns
  }

  static WildcardToRegex(pattern) {
    esc := RegExReplace(pattern, "([\\.^$+()\\[\\]{}|])", "\\$1")
    esc := StrReplace(esc, "*", ".*")
    esc := StrReplace(esc, "?", ".")
    return "i)^" . esc . "$"
  }

  static IncludeAllowed(relPath, includePatterns) {
    if (includePatterns.Length = 0)
      return true
    return this.AnyMatch(relPath, includePatterns)
  }

  static ExcludeBlocked(relPath, excludePatterns) {
    if (excludePatterns.Length = 0)
      return false
    return this.AnyMatch(relPath, excludePatterns)
  }

  static AnyMatch(text, regexList) {
    for _, rx in regexList {
      if (RegExMatch(text, rx))
        return true
    }
    return false
  }

  static NormalizeDir(path) {
    if (SubStr(path, -1) = "\\")
      return SubStr(path, 1, -1)
    return path
  }

  static RelPath(fullPath, root) {
    rootNorm := this.NormalizeDir(root) "\\"
    if (StrLower(SubStr(fullPath, 1, StrLen(rootNorm))) = StrLower(rootNorm))
      return SubStr(fullPath, StrLen(rootNorm) + 1)
    SplitPath fullPath, &name
    return name
  }
}
