#!/usr/bin/env bash
# install.sh — symlink khe-ai-rules into ~/.claude and ~/.codex

set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.claude" "$HOME/.codex"

link() {
    local src="$1" tgt="$2"
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

link "$repo/AGENTS.md"          "$HOME/.codex/AGENTS.md"
link "$repo/CLAUDE.md"          "$HOME/.claude/CLAUDE.md"
link "$repo/settings.json"      "$HOME/.claude/settings.json"
link "$repo/codex/config.toml"  "$HOME/.codex/config.toml"

echo
echo "Done. Source of truth: $repo"
