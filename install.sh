#!/usr/bin/env bash
# install.sh - symlink khe-ai-rules into ~/.claude and ~/.codex,
# and wire up umbrella-level AGENTS.md / CLAUDE.md at <KHE_ROOT>/.
#
# Re-runs are idempotent: existing correct symlinks are skipped.
#
# Layer model: see docs/resolution.md for how the user-global, umbrella,
# and per-project layers compose.

set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
khe_root="$(cd "$repo/.." && pwd)"

# On Windows git-bash / MSYS2, `ln -s` silently falls back to copying unless
# this is set. No effect on Linux/macOS.
export MSYS=winsymlinks:nativestrict

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

write_if_changed() {
    local content="$1" tgt="$2"
    if [[ -L "$tgt" ]]; then
        local backup="$tgt.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$tgt" "$backup"
        echo "  backup  $tgt -> $backup"
    elif [[ -f "$tgt" ]] && [[ "$(cat "$tgt")" == "$content" ]]; then
        echo "  skip    $tgt  (already current)"
        return
    fi
    printf '%s\n' "$content" > "$tgt"
    echo "  write   $tgt"
}

echo
echo "Installing khe-ai-rules from: $repo"
echo "KHE root:                     $khe_root"
echo

# User-global layer: ~/.claude/ and ~/.codex/
link "$repo/AGENTS.md"          "$HOME/.codex/AGENTS.md"
link "$repo/CLAUDE.md"          "$HOME/.claude/CLAUDE.md"
link "$repo/settings.json"      "$HOME/.claude/settings.json"
link "$repo/codex/config.toml"  "$HOME/.codex/config.toml"

# Directories - Claude Code lazy-loads skills/agents from ~/.claude/skills/ and ~/.claude/agents/
link "$repo/skills"             "$HOME/.claude/skills"
link "$repo/agents"             "$HOME/.claude/agents"
link "$repo/hooks"              "$HOME/.claude/hooks"

# Umbrella layer: <KHE_ROOT>/AGENTS.md and <KHE_ROOT>/CLAUDE.md.
# AGENTS.md is a symlink to khe-meta/ESTATE.md (estate index).
# CLAUDE.md is a real file containing `@AGENTS.md` - kept as a real file
# so the @-import resolves against the umbrella, not the symlink target.
echo
if [[ -f "$khe_root/khe-meta/ESTATE.md" ]]; then
    link             "$khe_root/khe-meta/ESTATE.md" "$khe_root/AGENTS.md"
    write_if_changed "@AGENTS.md"                   "$khe_root/CLAUDE.md"
else
    echo "  note    umbrella files (khe-meta/ESTATE.md not found at $khe_root/khe-meta/)"
    echo "          clone khe-meta under $khe_root and re-run."
fi

echo
echo "Done. Source of truth: $repo"
