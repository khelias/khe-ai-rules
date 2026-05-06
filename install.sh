#!/usr/bin/env bash
# install.sh - wire khe-ai-rules into the KHE umbrella as project-scoped
# Claude Code config.
#
# Layout (KHE_ROOT = parent dir of this repo):
#
#   <KHE_ROOT>/AGENTS.md          -> khe-ai-rules/AGENTS.md
#   <KHE_ROOT>/CLAUDE.md          -> khe-ai-rules/CLAUDE-umbrella.md (or CLAUDE.md if khe-meta missing)
#   <KHE_ROOT>/.claude/settings.json -> khe-ai-rules/settings.json
#   <KHE_ROOT>/.claude/skills/    -> khe-ai-rules/skills/
#   <KHE_ROOT>/.claude/agents/    -> khe-ai-rules/agents/
#   <KHE_ROOT>/.claude/hooks/     -> khe-ai-rules/hooks/
#
# Assumes Claude Code and Codex are always launched with cwd at <KHE_ROOT>.
# This install does NOT touch ~/.claude/ or ~/.codex/ - those belong to
# other projects on this machine and stay unaffected.
#
# Existing local files in <KHE_ROOT>/.claude/ (settings.local.json,
# launch.json, etc.) are preserved untouched.
#
# Re-runs are idempotent: existing correct symlinks are skipped, wrong
# ones are backed up before being replaced.

set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
khe_root="$(cd "$repo/.." && pwd)"

# On Windows git-bash / MSYS2, `ln -s` silently falls back to copying unless
# this is set. No effect on Linux/macOS.
export MSYS=winsymlinks:nativestrict

mkdir -p "$khe_root/.claude"

is_correct_link() {
    local src="$1" tgt="$2"
    [[ -L "$tgt" ]] && [[ "$(readlink -f "$tgt")" == "$(readlink -f "$src")" ]]
}

link() {
    local src="$1" tgt="$2"
    if [[ ! -e "$src" ]]; then
        echo "  miss    $src  (source missing, skipping)"
        return
    fi
    if is_correct_link "$src" "$tgt"; then
        echo "  skip    $tgt  (already linked)"
        return
    fi
    if [[ -e "$tgt" || -L "$tgt" ]]; then
        local backup="$tgt.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$tgt" "$backup"
        echo "  backup  $tgt -> $backup"
    fi
    ln -s "$src" "$tgt"
    echo "  link    $tgt"
}

echo
echo "Installing khe-ai-rules from: $repo"
echo "KHE root:                     $khe_root"
echo

# AGENTS.md - personal prefs for any agents.md-aware tool (Codex etc.)
link "$repo/AGENTS.md" "$khe_root/AGENTS.md"

# CLAUDE.md - umbrella variant if khe-meta is present, plain personal otherwise.
if [[ -f "$khe_root/khe-meta/ESTATE.md" ]]; then
    link "$repo/CLAUDE-umbrella.md" "$khe_root/CLAUDE.md"
else
    echo "  note    khe-meta/ESTATE.md not found at $khe_root/khe-meta/"
    echo "          falling back to CLAUDE.md without estate index."
    echo "          clone khe-meta under $khe_root and re-run for full umbrella."
    link "$repo/CLAUDE.md" "$khe_root/CLAUDE.md"
fi

# Project-scoped Claude Code config under <KHE_ROOT>/.claude/.
# Local files (settings.local.json, launch.json, etc.) are not touched.
link "$repo/settings.json" "$khe_root/.claude/settings.json"
link "$repo/skills"        "$khe_root/.claude/skills"
link "$repo/agents"        "$khe_root/.claude/agents"
link "$repo/hooks"         "$khe_root/.claude/hooks"

echo
echo "Done. Source of truth: $repo"
echo "Edit files in this repo; symlinks reflect changes immediately."
