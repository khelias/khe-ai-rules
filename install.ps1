# install.ps1 — symlink khe-ai-rules into ~/.claude and ~/.codex
#
# Windows requires Developer Mode enabled OR an admin PowerShell to create
# symlinks. Without either, this script falls back to file copy and warns.
#
# Enable Developer Mode: Settings -> Privacy & security -> For developers

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$claudeDir = Join-Path $env:USERPROFILE ".claude"
$codexDir  = Join-Path $env:USERPROFILE ".codex"

New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
New-Item -ItemType Directory -Force -Path $codexDir | Out-Null

function Link-File {
    param([string]$source, [string]$target)
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
        Copy-Item -Path $source -Destination $target
        Write-Host "  copy    $target  (symlink failed; re-run after edits)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "Installing khe-ai-rules from: $repoRoot"
Write-Host ""

Link-File "$repoRoot\AGENTS.md"          "$codexDir\AGENTS.md"
Link-File "$repoRoot\CLAUDE.md"          "$claudeDir\CLAUDE.md"
Link-File "$repoRoot\settings.json"      "$claudeDir\settings.json"
Link-File "$repoRoot\codex\config.toml"  "$codexDir\config.toml"

Write-Host ""
Write-Host "Done. Source of truth: $repoRoot" -ForegroundColor Green
Write-Host "Edit files in this repo; symlinks reflect changes immediately."
