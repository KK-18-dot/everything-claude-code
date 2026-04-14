param(
  [Parameter(Mandatory = $true)]
  [string]$EventName
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Read stdin JSON if present; fail-safe if not JSON.
$raw = [Console]::In.ReadToEnd()
$payload = $null
if ($raw -and $raw.Trim().Length -gt 0) {
  try {
    $payload = $raw | ConvertFrom-Json -ErrorAction Stop
  } catch {
    $payload = $null
  }
}

$tool = $null
$command = $null
$filePath = $null
if ($payload) {
  try {
    if ($payload.tool) { $tool = [string]$payload.tool }
    elseif ($payload.tool_name) { $tool = [string]$payload.tool_name }

    if ($payload.tool_input) {
      if ($payload.tool_input.command) { $command = [string]$payload.tool_input.command }
      if ($payload.tool_input.file_path) { $filePath = [string]$payload.tool_input.file_path }
      elseif ($payload.tool_input.path) { $filePath = [string]$payload.tool_input.path }
    }
  } catch {
    $tool = $null
    $command = $null
    $filePath = $null
  }
}

$warnings = New-Object System.Collections.Generic.List[string]
$actions = New-Object System.Collections.Generic.List[string]

function Sanitize-LogValue([string]$value) {
  if (-not $value) { return '' }
  if ($value -match '(?i)token|secret|key|authorization|password') { return '<redacted>' }
  $v = $value -replace '"', "'"
  $v = $v -replace '\s+', ' '
  return $v.Trim()
}

function Get-CompactCounterPath {
  $base = $env:TEMP
  if (-not $base) { $base = 'C:\Users\kawad\DevSandbox' }
  return (Join-Path $base 'claude-compact-counter.json')
}

function Get-CompactCount {
  $path = Get-CompactCounterPath
  if (-not (Test-Path $path)) { return 0 }
  try {
    $raw = Get-Content -Path $path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) { return 0 }
    $obj = $raw | ConvertFrom-Json
    if ($obj -and $obj.count -is [int]) { return $obj.count }
  } catch { }
  return 0
}

function Set-CompactCount([int]$count) {
  $path = Get-CompactCounterPath
  try {
    $obj = [pscustomobject]@{ count = $count; updatedAt = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') }
    $obj | ConvertTo-Json -Compress | Set-Content -Path $path -Encoding utf8
  } catch { }
}

function In-GitRepo {
  try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
  } catch {
    return $false
  }
}

function Get-GitDiffText {
  if (-not (In-GitRepo)) { return '' }
  try {
    $diff = git diff -U0 2>$null
    $cached = git diff --cached -U0 2>$null
    return ($diff + "`n" + $cached)
  } catch {
    return ''
  }
}

function Has-AddedPattern([string]$diffText, [string]$pattern) {
  if (-not $diffText) { return $false }
  foreach ($line in $diffText -split "`n") {
    if ($line.StartsWith('+++')) { continue }
    if ($line.StartsWith('+') -and $line -match $pattern) { return $true }
  }
  return $false
}

function Has-PossibleSecretInDiff([string]$diffText) {
  if (-not $diffText) { return $false }
  $patterns = @(
    '(?i)\b(api[_-]?key|secret|token|password)\b',
    '(?i)\bauthorization\b',
    '(?i)bearer\s+[a-z0-9\-\._=]{10,}',
    '(?i)-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----',
    '(?i)\bsk-[a-z0-9]{20,}\b',
    '(?i)\bAKIA[0-9A-Z]{16}\b',
    '(?i)\bAIza[0-9A-Za-z\-_]{35}\b'
  )
  foreach ($line in $diffText -split "`n") {
    if ($line.StartsWith('+++')) { continue }
    if (-not $line.StartsWith('+')) { continue }
    foreach ($pattern in $patterns) {
      if ($line -match $pattern) { return $true }
    }
  }
  return $false
}

function Is-DestructiveCommand([string]$cmd) {
  if (-not $cmd) { return $false }
  $patterns = @(
    '(?i)\brm\s+-rf\b',
    '(?i)\bdel\s+/f\b',
    '(?i)\brd\s+/s\s+/q\b',
    '(?i)\brmdir\s+/s\s+/q\b',
    '(?i)\bRemove-Item\b.*-Recurse.*-Force',
    '(?i)\bgit\s+reset\s+--hard\b',
    '(?i)\bgit\s+clean\s+-fdx\b',
    '(?i)\bformat\b',
    '(?i)\bmkfs\b',
    '(?i)\bdd\s+if='
  )
  foreach ($pattern in $patterns) {
    if ($cmd -match $pattern) { return $true }
  }
  return $false
}

function Is-JsTsFile([string]$path) {
  if (-not $path) { return $false }
  $ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
  return @('.js','.jsx','.ts','.tsx','.mjs','.cjs') -contains $ext
}

function Find-TsConfigRoot([string]$startDir) {
  if (-not $startDir) { return $null }
  $dir = $startDir
  while ($dir -and (Test-Path $dir)) {
    if (Test-Path (Join-Path $dir 'tsconfig.json')) { return $dir }
    $parent = Split-Path $dir -Parent
    if (-not $parent -or $parent -eq $dir) { break }
    $dir = $parent
  }
  return $null
}

function Is-DocsPath([string]$path) {
  if (-not $path) { return $false }
  $norm = $path -replace '\\', '/'
  if ($norm -match '(?i)(^|/)docs/') { return $true }
  $file = [System.IO.Path]::GetFileName($norm)
  if ($file -match '(?i)^readme(\\.|$)') { return $true }
  return $false
}

function Find-PackageRoot([string]$startDir) {
  if (-not $startDir) { return $null }
  $dir = $startDir
  while ($dir -and (Test-Path $dir)) {
    if (Test-Path (Join-Path $dir 'package.json')) { return $dir }
    $parent = Split-Path $dir -Parent
    if (-not $parent -or $parent -eq $dir) { break }
    $dir = $parent
  }
  return $null
}

function Get-LocalBin([string]$root, [string]$binName) {
  if (-not $root) { return $null }
  $path = Join-Path $root (Join-Path 'node_modules\\.bin' $binName)
  if (Test-Path $path) { return $path }
  return $null
}

function Has-Command([string]$name) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  return [bool]$cmd
}

function Get-TestScript([string]$pkgRoot) {
  if (-not $pkgRoot) { return $null }
  $pkgPath = Join-Path $pkgRoot 'package.json'
  if (-not (Test-Path $pkgPath)) { return $null }
  try {
    $pkg = Get-Content -Path $pkgPath -Raw | ConvertFrom-Json
    if ($pkg.scripts -and $pkg.scripts.test) { return [string]$pkg.scripts.test }
  } catch { }
  return $null
}

function Is-HeavyTestScript([string]$script) {
  if (-not $script) { return $false }
  return ($script -match '(?i)playwright|cypress|e2e|coverage|--watch|--runInBand')
}

function Get-GitRoot {
  if (-not (In-GitRepo)) { return '' }
  try {
    return (git rev-parse --show-toplevel 2>$null).Trim()
  } catch {
    return ''
  }
}

function Get-GitBranch {
  if (-not (In-GitRepo)) { return '' }
  try {
    return (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
  } catch {
    return ''
  }
}

function Get-GitStatusShort {
  if (-not (In-GitRepo)) { return @() }
  try {
    return (git status --short 2>$null) -split "`n"
  } catch {
    return @()
  }
}

function Get-GitChangedFiles {
  if (-not (In-GitRepo)) { return @() }
  $files = New-Object System.Collections.Generic.List[string]
  try {
    $a = (git diff --name-only 2>$null) -split "`n"
    $b = (git diff --cached --name-only 2>$null) -split "`n"
    foreach ($f in $a) { if ($f) { $files.Add($f) | Out-Null } }
    foreach ($f in $b) { if ($f) { $files.Add($f) | Out-Null } }
  } catch { }
  return $files
}

function Filter-SensitivePaths([string[]]$paths) {
  $safe = New-Object System.Collections.Generic.List[string]
  foreach ($p in $paths) {
    if (-not $p) { continue }
    if ($p -match '(?i)(^|/|\\)\\.env(\\.|$)') { continue }
    if ($p -match '(?i)(^|/|\\)secrets(\\|/)') { continue }
    $safe.Add($p) | Out-Null
  }
  return $safe
}

function Write-SessionLog([string]$eventName, [string]$tool, [string]$command, [string]$filePath) {
  if ($env:CLAUDE_SESSION_LOG -ne '1') { return }
  $base = 'C:\Users\kawad\DevSandbox\session-logs'
  try { New-Item -ItemType Directory -Force -Path $base | Out-Null } catch { return }
  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $logPath = Join-Path $base ("claude-session-$timestamp.txt")
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
  $lines.Add("event: $eventName") | Out-Null
  $lines.Add("tool: $(Sanitize-LogValue $tool)") | Out-Null
  $lines.Add("command: $(Sanitize-LogValue $command)") | Out-Null
  $lines.Add("file: $(Sanitize-LogValue $filePath)") | Out-Null

  $root = Get-GitRoot
  if ($root) { $lines.Add("repo: $root") | Out-Null }
  $branch = Get-GitBranch
  if ($branch) { $lines.Add("branch: $branch") | Out-Null }
  $status = Get-GitStatusShort
  if ($status.Count -gt 0) {
    $lines.Add("status:") | Out-Null
    foreach ($s in $status) { if ($s) { $lines.Add("  $s") | Out-Null } }
  }
  $changed = Filter-SensitivePaths (Get-GitChangedFiles)
  if ($changed.Count -gt 0) {
    $lines.Add("changed_files:") | Out-Null
    foreach ($c in $changed) { $lines.Add("  $c") | Out-Null }
  }

  try { $lines | Set-Content -Path $logPath -Encoding utf8 } catch { }
}

function Invoke-ProcessWithTimeout([string]$filePath, [string[]]$args, [string]$workDir, [int]$timeoutSec) {
  try {
    $tmpOut = [System.IO.Path]::GetTempFileName()
    $tmpErr = [System.IO.Path]::GetTempFileName()
    $p = Start-Process -FilePath $filePath -ArgumentList $args -WorkingDirectory $workDir -NoNewWindow -PassThru `
      -RedirectStandardOutput $tmpOut -RedirectStandardError $tmpErr
    $exited = $p.WaitForExit($timeoutSec * 1000)
    if (-not $exited) {
      try { Stop-Process -Id $p.Id -Force } catch { }
      return 'timeout'
    }
    if ($p.ExitCode -eq 0) { return 'ok' }
    return 'failed'
  } catch {
    return 'failed'
  } finally {
    if ($tmpOut -and (Test-Path $tmpOut)) { Remove-Item $tmpOut -Force }
    if ($tmpErr -and (Test-Path $tmpErr)) { Remove-Item $tmpErr -Force }
  }
}

$mode = $env:HOOK_MODE
if ([string]::IsNullOrWhiteSpace($mode)) { $mode = 'warning' }
$mode = $mode.ToLowerInvariant()
$activeMode = ($mode -eq 'active')

switch ($EventName) {
  'PreToolUse' {
    $compactThreshold = 25
    $count = Get-CompactCount
    $count++
    if ($count -ge $compactThreshold) {
      $warnings.Add('WARNING: Consider running /compact after exploration or before the next major step.') | Out-Null
      $count = 0
    }
    Set-CompactCount $count

    if ($command) {
      $cmdTrim = $command.Trim()
      $firstToken = ''
      if ($cmdTrim.Length -gt 0) {
        $firstToken = ($cmdTrim -split '\s+')[0].ToLowerInvariant()
      }
      $longCmds = @('npm','pnpm','yarn','bun','cargo','pytest','vitest','playwright','docker','make')
      if ($longCmds -contains $firstToken) {
        $warnings.Add('WARNING: This command may take time. Consider running it when you can monitor progress.') | Out-Null
      }
      if (Is-DestructiveCommand $command) {
        $warnings.Add('WARNING: This command looks destructive. Double-check before running.') | Out-Null
      }
      if ($command -match '(?i)\bgit\s+push\b') {
        $warnings.Add('WARNING: Consider reviewing changes before git push.') | Out-Null
      }
    }
    if ($tool -eq 'Write' -and $filePath) {
      $isDoc = $filePath -match '(?i)\.(md|txt)$'
      $isAllowed = $filePath -match '(?i)(README|CLAUDE|AGENTS|CONTRIBUTING)\.md$'
      $pathNorm = $filePath -replace '\\', '/'
      $isDocsFolder = $pathNorm -match '(?i)(^|/)docs/'
      if ($isDoc -and -not $isAllowed -and -not $isDocsFolder) {
        $warnings.Add('WARNING: Consider consolidating docs into README.md/CLAUDE.md/AGENTS.md/CONTRIBUTING.md.') | Out-Null
      }
    }
    break
  }
  'PostToolUse' {
    $warnings.Add('WARNING: Consider running format, typecheck, and tests for this change.') | Out-Null

    if ($filePath -and (Test-Path $filePath)) {
      try {
        $hasConsole = Select-String -Path $filePath -Pattern 'console.log' -SimpleMatch -Quiet
        if ($hasConsole) {
          $warnings.Add('WARNING: console.log found in edited file. Consider removing before commit.') | Out-Null
        }
      } catch { }
    }

    $activeEligible = $false
    if ($activeMode -and ($tool -eq 'Edit' -or $tool -eq 'Update')) {
      if ($filePath -and (Test-Path $filePath) -and (Is-JsTsFile $filePath)) {
        $activeEligible = $true
      }
    }

    if ($activeEligible) {
      $actions.Add('HOOK_MODE=active summary:') | Out-Null
      $startDir = Split-Path $filePath -Parent
      $pkgRoot = Find-PackageRoot $startDir

      # Prettier (JS/TS only)
      if (-not $filePath) {
        $actions.Add('prettier: skipped') | Out-Null
      } elseif (-not (Test-Path $filePath)) {
        $actions.Add('prettier: skipped') | Out-Null
      } elseif (-not (Is-JsTsFile $filePath)) {
        $actions.Add('prettier: skipped') | Out-Null
      } else {
        $prettierPath = Get-LocalBin $pkgRoot 'prettier.cmd'
        if ($prettierPath) {
          $status = Invoke-ProcessWithTimeout $prettierPath @('--write', $filePath) $pkgRoot 60
          $actions.Add("prettier: $status") | Out-Null
        } elseif (Has-Command 'npx') {
          $status = Invoke-ProcessWithTimeout 'cmd.exe' @('/c','npx','-y','prettier','--write',$filePath) ($pkgRoot ?? $startDir) 60
          $actions.Add("prettier: $status") | Out-Null
        } else {
          $actions.Add('prettier: skipped') | Out-Null
        }
      }

      # tsc (TS project only)
      $tsRoot = Find-TsConfigRoot $startDir
      if (-not $tsRoot) {
        $actions.Add('tsc: skipped') | Out-Null
      } else {
        $tscPath = Get-LocalBin $tsRoot 'tsc.cmd'
        if (-not $tscPath -and $pkgRoot) { $tscPath = Get-LocalBin $pkgRoot 'tsc.cmd' }
        if ($tscPath) {
          $status = Invoke-ProcessWithTimeout $tscPath @('--noEmit','--pretty','false') $tsRoot 60
          $actions.Add("tsc: $status") | Out-Null
        } elseif (Has-Command 'npx') {
          $status = Invoke-ProcessWithTimeout 'cmd.exe' @('/c','npx','-y','tsc','--noEmit','--pretty','false') $tsRoot 60
          $actions.Add("tsc: $status") | Out-Null
        } else {
          $actions.Add('tsc: skipped') | Out-Null
        }
      }

      # npm test (if script exists)
      if (-not $pkgRoot) {
        $actions.Add('npm test: skipped') | Out-Null
      } else {
        $testScript = Get-TestScript $pkgRoot
        if (-not $testScript) {
          $actions.Add('npm test: skipped') | Out-Null
        } elseif ($testScript -match '(?i)no test specified') {
          $actions.Add('npm test: skipped') | Out-Null
        } elseif (Is-HeavyTestScript $testScript) {
          $actions.Add('npm test: skipped') | Out-Null
        } elseif ($filePath -and (Is-DocsPath $filePath)) {
          $actions.Add('npm test: skipped') | Out-Null
        } else {
          $status = Invoke-ProcessWithTimeout 'cmd.exe' @('/c','npm','test') $pkgRoot 60
          $actions.Add("npm test: $status") | Out-Null
        }
      }
    }
    break
  }
  'Stop' {
    $diffText = Get-GitDiffText
    if ($diffText) {
      if (Has-PossibleSecretInDiff $diffText) {
        $warnings.Add('WARNING: git diff contains possible secrets. Remove or rotate before commit.') | Out-Null
      }
      if ($diffText -match '(?i)\bconsole\.log\b' -or $diffText -match '\bTODO\b' -or $diffText -match '\bFIXME\b') {
        $warnings.Add('WARNING: git diff contains console.log / TODO / FIXME. Consider cleaning before commit.') | Out-Null
      }
    }
    Write-SessionLog $EventName $tool $command $filePath
    break
  }
  default { }
}

if ($env:CLAUDE_HOOK_DEBUG -eq '1') {
  try {
    $logPath = 'C:\Users\kawad\.claude\hooks\hook.log'
    $toolLog = Sanitize-LogValue $tool
    $cmdLog = Sanitize-LogValue $command
    $pathLog = Sanitize-LogValue $filePath
    if ([string]::IsNullOrWhiteSpace($toolLog)) { $toolLog = '(unknown)' }
    if ([string]::IsNullOrWhiteSpace($cmdLog)) { $cmdLog = '<none>' }
    if ([string]::IsNullOrWhiteSpace($pathLog)) { $pathLog = '<none>' }
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') event=$EventName tool=$toolLog cmd=`"$cmdLog`" path=`"$pathLog`""
    Add-Content -Path $logPath -Value $line -Encoding utf8
  } catch {
    # Ignore logging failures
  }
}

$emit = $warnings.Count -gt 0
if ($activeMode -and $EventName -eq 'PostToolUse') { $emit = $true }

if ($emit) {
  $lines = New-Object System.Collections.Generic.List[string]
  foreach ($w in $warnings) { $lines.Add($w) | Out-Null }
  foreach ($a in $actions) { $lines.Add($a) | Out-Null }

  if ($lines.Count -gt 0) {
    $msg = ($lines -join "`n")
    $out = [pscustomobject]@{ systemMessage = $msg; suppressOutput = $true }
    $out | ConvertTo-Json -Compress
  }
}

exit 0
