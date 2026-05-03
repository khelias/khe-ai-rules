# How AI agents find these files

Reference for how `AGENTS.md` and `CLAUDE.md` files are discovered and merged
across the three layers used in the KHE estate. Verified against canonical
docs (sources at the bottom).

## The three layers

| Layer | Where | Loaded as | Set up by |
|-------|-------|-----------|-----------|
| **User-global** | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` | Always loaded, every session, every project. Personal preferences only. | `khe-ai-rules/install.{sh,ps1}` symlinks both to this repo. |
| **Umbrella** | `<KHE_ROOT>/AGENTS.md`, `<KHE_ROOT>/CLAUDE.md` | Loaded when CWD is the umbrella, or auto-discovered by tools that walk up from a sub-repo. Estate index, cross-repo map. | `install.{sh,ps1}` symlinks both files to `khe-meta/ESTATE.md`. Markdown is markdown - the same content works as AGENTS.md and CLAUDE.md. |
| **Project** | `<KHE_ROOT>/khe-*/AGENTS.md`, `<KHE_ROOT>/khe-*/CLAUDE.md` | Loaded when working in that repo. Project-specific commands, architecture, invariants. | Tracked in each project's git repo. |

The three layers compose: more specific layers add to (and can override)
broader ones. Same model as `git config --system` / `--global` / `--local`.

## Claude Code (`CLAUDE.md`)

[Source: code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory)

- **Walks UP the directory tree from CWD**, reading every `CLAUDE.md` it
  finds. All files concatenated; closer files load last (so they win
  conflicts).
- `~/.claude/CLAUDE.md` is the user-level scope, always loaded.
- **Sub-directory CLAUDE.md files load lazily** - only when Claude reads or
  edits a file in that subtree.
- `@path` imports are resolved relative to the file containing the import.
  Max import depth: 5.
- **Claude Code reads `CLAUDE.md`, not `AGENTS.md`.** To pick up an
  AGENTS.md, the matching CLAUDE.md must `@`-import it (the pattern this
  repo uses everywhere).

What this means for KHE: when you start Claude in `<KHE_ROOT>/`, only the
user-global and umbrella layers load up front. Per-project layers come in
the moment Claude touches a file in that project.

## Codex / Cursor / Aider / others (`AGENTS.md`)

[Source: agents.md spec](https://agents.md/)

- "Place another `AGENTS.md` inside each package. Agents automatically read
  the **nearest file in the directory tree**, so the closest one takes
  precedence."
- The spec defines monorepo discovery; non-git umbrella folders are
  unspecified, but in practice tools walk up the same way Claude Code does.

What this means for KHE: tools find the closest `AGENTS.md` to the file
being edited. Working inside `khe-homelab/`, they get
`khe-homelab/AGENTS.md`. Working at the umbrella root, they get
`<KHE_ROOT>/AGENTS.md` (the symlink to `ESTATE.md`).

## Why both umbrella files symlink to the same target

`khe-meta/ESTATE.md` is plain markdown with no `@`-imports. Its content
(estate index, deploy map, per-repo roadmap pointers) is what we want
loaded when AI agents start at the umbrella, regardless of whether the
tool reads `AGENTS.md` (Codex/Cursor/Aider) or `CLAUDE.md` (Claude
Code). Symlinking both files to the same source means one file to
maintain, two filenames so each tool finds what it expects.

If you ever need Claude-specific umbrella content (e.g. extra
instructions only relevant to Claude Code), break the CLAUDE.md
symlink, replace it with a real file, and `@`-import ESTATE.md plus
the extras. Until then, the dual-symlink keeps things minimal.

## Multi-machine setup

Clone `khe-ai-rules` and `khe-meta` under the same parent directory on
each machine, then run `khe-ai-rules/install.{sh,ps1}`. The script
infers `<KHE_ROOT>` as its own parent and creates:

- User-global symlinks under `~/.claude/` and `~/.codex/`.
- Umbrella `<KHE_ROOT>/AGENTS.md` and `<KHE_ROOT>/CLAUDE.md`, both
  symlinked to `khe-meta/ESTATE.md`.

If `khe-meta/` is not cloned, the umbrella step is skipped with a
warning (the user-global step still completes).

## Sources

- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - resolution rules, `@import`, lazy sub-dir loading.
- [agents.md spec](https://agents.md/) - nearest-file discovery, monorepo guidance.
- Published patterns aligned with this layout: [Spine pattern](https://tsoporan.com/blog/spine-pattern-multi-repo-ai-development/), [Virtual Monorepo pattern](https://medium.com/devops-ai/the-virtual-monorepo-pattern-how-i-gave-claude-code-full-system-context-across-35-repos-43b310c97db8).
- Symlink-into-`~/.claude` as a recognized practice: [SSW rule](https://www.ssw.com.au/rules/symlink-agents-to-claude).
