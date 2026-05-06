# install.ps1 - wire khe-ai-rules into the KHE umbrella as project-scoped
# Claude Code config.
#
# Layout (KHE_ROOT = parent dir of this repo):
#
#   <KHE_ROOT>\AGENTS.md            -> khe-ai-rules\AGENTS.md
#   <KHE_ROOT>\CLAUDE.md            -> khe-ai-rules\CLAUDE-umbrella.md (or CLAUDE.md if khe-meta missing)
#   <KHE_ROOT>\.claude\settings.json -> khe-ai-rules\settings.json
#   <KHE_ROOT>\.claude\skills\      -> khe-ai-rules\skills\
#   <KHE_ROOT>\.claude\agents\      -> khe-ai-rules\agents\
#   <KHE_ROOT>\.claude\hooks\       -> khe-ai-rules\hooks\
#
# Assumes Claude Code and Codex are always launched with cwd at <KHE_ROOT>.
# This install does NOT touch ~/.claude/ or ~/.codex/ - those belong to
# other projects on this machine and stay unaffected.
#
# Existing local files in <KHE_ROOT>\.claude\ (settings.local.json,
# launch.json, etc.) are preserved untouched.
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
$kheRoot  = Split-Path -Parent $repoRoot

$claudeProjectDir = Join-Path $kheRoot ".claude"
New-Item -ItemType Directory -Force -Path $claudeProjectDir | Out-Null

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
    if (-not (Test-Path $source)) {
        Write-Host "  miss    $source  (source missing, skipping)" -ForegroundColor DarkGray
        return
    }
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
Write-Host "KHE root:                     $kheRoot"
Write-Host ""

# AGENTS.md - personal prefs for any agents.md-aware tool (Codex etc.)
Link-Path "$repoRoot\AGENTS.md" "$kheRoot\AGENTS.md" "file"

# CLAUDE.md - umbrella variant if khe-meta is present, plain personal otherwise.
$estateSource = Join-Path $kheRoot "khe-meta\ESTATE.md"
if (Test-Path $estateSource) {
    Link-Path "$repoRoot\CLAUDE-umbrella.md" "$kheRoot\CLAUDE.md" "file"
} else {
    Write-Host "  note    khe-meta\ESTATE.md not found at $kheRoot\khe-meta\" -ForegroundColor DarkGray
    Write-Host "          falling back to CLAUDE.md without estate index." -ForegroundColor DarkGray
    Write-Host "          clone khe-meta under $kheRoot and re-run for full umbrella." -ForegroundColor DarkGray
    Link-Path "$repoRoot\CLAUDE.md" "$kheRoot\CLAUDE.md" "file"
}

# Project-scoped Claude Code config under <KHE_ROOT>\.claude\.
# Local files (settings.local.json, launch.json, etc.) are not touched.
Link-Path "$repoRoot\settings.json" "$claudeProjectDir\settings.json" "file"
Link-Path "$repoRoot\skills"        "$claudeProjectDir\skills"        "dir"
Link-Path "$repoRoot\agents"        "$claudeProjectDir\agents"        "dir"
Link-Path "$repoRoot\hooks"         "$claudeProjectDir\hooks"         "dir"

Write-Host ""
Write-Host "Done. Source of truth: $repoRoot" -ForegroundColor Green
Write-Host "Edit files in this repo; symlinks reflect changes immediately."
