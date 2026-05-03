# install.ps1 - symlink khe-ai-rules into ~/.claude and ~/.codex
#
# Windows requires Developer Mode enabled OR an admin PowerShell to create
# symlinks. With Dev Mode enabled, sign out + sign in once after enabling
# so your session token gets the SeCreateSymbolicLinkPrivilege.
#
# Without either: file symlinks fall back to copy (re-run after edits to sync).
# Directory symlinks cannot fall back - they require admin or Dev Mode.
#
# Re-runs are idempotent: existing correct symlinks are skipped.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

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

Write-Host ""
Write-Host "Installing khe-ai-rules from: $repoRoot"
Write-Host ""

# Files
Link-Path "$repoRoot\AGENTS.md"          "$codexDir\AGENTS.md"           "file"
Link-Path "$repoRoot\CLAUDE.md"          "$claudeDir\CLAUDE.md"          "file"
Link-Path "$repoRoot\settings.json"      "$claudeDir\settings.json"      "file"
Link-Path "$repoRoot\codex\config.toml"  "$codexDir\config.toml"         "file"

# Directories - Claude Code lazy-loads skills/agents from ~/.claude/skills/ and ~/.claude/agents/
Link-Path "$repoRoot\skills"             "$claudeDir\skills"             "dir"
Link-Path "$repoRoot\agents"             "$claudeDir\agents"             "dir"
Link-Path "$repoRoot\hooks"              "$claudeDir\hooks"              "dir"

Write-Host ""
Write-Host "Done. Source of truth: $repoRoot" -ForegroundColor Green
Write-Host "Edit files in this repo; symlinks reflect changes immediately."
