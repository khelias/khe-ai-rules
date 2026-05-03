# install.ps1 - symlink khe-ai-rules into ~/.claude and ~/.codex,
# and wire up umbrella-level AGENTS.md / CLAUDE.md at <KHE_ROOT>/.
#
# Windows requires Developer Mode enabled OR an admin PowerShell to create
# symlinks. With Dev Mode enabled, sign out + sign in once after enabling
# so your session token gets the SeCreateSymbolicLinkPrivilege.
#
# Without either: file symlinks fall back to copy (re-run after edits to sync).
# Directory symlinks cannot fall back - they require admin or Dev Mode.
#
# Re-runs are idempotent: existing correct symlinks are skipped.
#
# Layer model: see docs/resolution.md for how the user-global, umbrella,
# and per-project layers compose.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$kheRoot  = Split-Path -Parent $repoRoot

$claudeDir = Join-Path $env:USERPROFILE ".claude"
$codexDir  = Join-Path $env:USERPROFILE ".codex"

New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
New-Item -ItemType Directory -Force -Path $codexDir  | Out-Null

function Test-CorrectLink {
    param([string]$source, [string]$target)
    if (-not (Test-Path $target)) { return $false }
    $item = Get-Item $target -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    if ($item.LinkType -ne "SymbolicLink") { return $false }
    try {
        return ([IO.Path]::GetFullPath($item.Target) -ieq [IO.Path]::GetFullPath($source))
    } catch {
        return $false
    }
}

function Link-Path {
    param([string]$source, [string]$target, [string]$kind)
    if (Test-CorrectLink $source $target) {
        Write-Host "  skip    $target  (already linked)" -ForegroundColor DarkGray
        return
    }
    if (Test-Path $target) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "$target.backup-$stamp"
        Move-Item -Path $target -Destination $backup
        Write-Host "  backup  $target -> $backup" -ForegroundColor Yellow
    }
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
        Write-Host "  link    $target" -ForegroundColor Green
    } catch {
        if ($kind -eq "file") {
            Copy-Item -Path $source -Destination $target
            Write-Host "  copy    $target  (symlink failed; re-run after edits)" -ForegroundColor Cyan
        } else {
            Write-Host "  FAIL    $target  (cannot symlink directory; need admin or Dev Mode)" -ForegroundColor Red
        }
    }
}

function Write-IfChanged {
    param([string]$content, [string]$target)
    if (Test-Path $target) {
        $item = Get-Item $target -Force -ErrorAction SilentlyContinue
        if ($item.LinkType -eq "SymbolicLink") {
            $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backup = "$target.backup-$stamp"
            Move-Item -Path $target -Destination $backup
            Write-Host "  backup  $target -> $backup" -ForegroundColor Yellow
        } else {
            $current = Get-Content -Raw $target
            if ($current -eq "$content`n" -or $current -eq "$content`r`n") {
                Write-Host "  skip    $target  (already current)" -ForegroundColor DarkGray
                return
            }
        }
    }
    Set-Content -Path $target -Value $content -NoNewline:$false
    Write-Host "  write   $target" -ForegroundColor Green
}

Write-Host ""
Write-Host "Installing khe-ai-rules from: $repoRoot"
Write-Host "KHE root:                     $kheRoot"
Write-Host ""

# User-global layer: ~/.claude/ and ~/.codex/
Link-Path "$repoRoot\AGENTS.md"          "$codexDir\AGENTS.md"           "file"
Link-Path "$repoRoot\CLAUDE.md"          "$claudeDir\CLAUDE.md"          "file"
Link-Path "$repoRoot\settings.json"      "$claudeDir\settings.json"      "file"
Link-Path "$repoRoot\codex\config.toml"  "$codexDir\config.toml"         "file"

# Directories - Claude Code lazy-loads skills/agents from ~/.claude/skills/ and ~/.claude/agents/
Link-Path "$repoRoot\skills"             "$claudeDir\skills"             "dir"
Link-Path "$repoRoot\agents"             "$claudeDir\agents"             "dir"
Link-Path "$repoRoot\hooks"              "$claudeDir\hooks"              "dir"

# Umbrella layer: <KHE_ROOT>/AGENTS.md and <KHE_ROOT>/CLAUDE.md.
# AGENTS.md is a symlink to khe-meta/ESTATE.md (estate index).
# CLAUDE.md is a real file containing `@AGENTS.md` - kept as a real file
# so the @-import resolves against the umbrella, not the symlink target.
Write-Host ""
$estateSource = Join-Path $kheRoot "khe-meta\ESTATE.md"
if (Test-Path $estateSource) {
    Link-Path        $estateSource           "$kheRoot\AGENTS.md"       "file"
    Write-IfChanged  "@AGENTS.md"            "$kheRoot\CLAUDE.md"
} else {
    Write-Host "  note    umbrella files (khe-meta\ESTATE.md not found at $kheRoot\khe-meta\)" -ForegroundColor DarkGray
    Write-Host "          clone khe-meta under $kheRoot and re-run." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Done. Source of truth: $repoRoot" -ForegroundColor Green
Write-Host "Edit files in this repo; symlinks reflect changes immediately."
