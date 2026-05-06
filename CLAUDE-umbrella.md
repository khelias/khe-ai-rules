# KHE umbrella CLAUDE.md

Loaded when Claude Code starts in `<KHE_ROOT>/`. This file is the
symlink target of `<KHE_ROOT>/CLAUDE.md`, created by
`khe-ai-rules/install.{sh,ps1}` when both `khe-ai-rules` and `khe-meta`
are cloned under the same parent.

It composes two umbrella-layer sources via `@`-imports:

- `AGENTS.md` (this repo) - personal preferences for AI agents.
- `../khe-meta/ESTATE.md` - canonical KHE estate index.

`@`-paths resolve relative to this file's location (per Anthropic's
Claude Code memory docs), so the imports work regardless of where the
symlink lives.

@AGENTS.md
@../khe-meta/ESTATE.md

## Claude Code only

Tool-agnostic instructions belong in `AGENTS.md`. This section is for
Claude-specific extensions: plan-mode hints, hook references, subagent
dispatch preferences, slash command notes, etc.
