#!/usr/bin/env bash
# install.sh — symlink khe-ai-rules into ~/.claude and ~/.codex
#
# Re-runs are idempotent: existing correct symlinks are skipped.

set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.claude" "$HOME/.codex"

is_correct_link() {
    local src="$1" tgt="$2"
    [[ -L "$tgt" ]] && [[ "$(readlink -f "$tgt")" == "$(readlink -f "$src")" ]]
}

link() {
    local src="$1" tgt="$2"
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
echo

# Files
link "$repo/AGENTS.md"          "$HOME/.codex/AGENTS.md"
link "$repo/CLAUDE.md"          "$HOME/.claude/CLAUDE.md"
link "$repo/settings.json"      "$HOME/.claude/settings.json"
link "$repo/codex/config.toml"  "$HOME/.codex/config.toml"

# Directories — Claude Code lazy-loads skills/agents from ~/.claude/skills/ and ~/.claude/agents/
link "$repo/skills"             "$HOME/.claude/skills"
link "$repo/agents"             "$HOME/.claude/agents"
link "$repo/hooks"              "$HOME/.claude/hooks"

echo
echo "Done. Source of truth: $repo"
