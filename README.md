# khe-ai-rules

[![CI](https://github.com/khelias/khe-ai-rules/actions/workflows/ci.yml/badge.svg)](https://github.com/khelias/khe-ai-rules/actions/workflows/ci.yml)

Personal AI coding agent configuration for [Claude Code](https://claude.com/claude-code), [OpenAI Codex CLI](https://developers.openai.com/codex/), and any tool that reads `AGENTS.md`.

## What this is

A small, hand-written foundation built directly from canonical sources - not forked from anyone else's framework.

It does four jobs:

1. **User-level config** - `AGENTS.md` and `CLAUDE.md` here are symlinked into `~/.codex/` and `~/.claude/`, so every project on every machine sees the same personal preferences.
2. **Umbrella context wiring** - `install.{sh,ps1}` also symlinks `<KHE_ROOT>/AGENTS.md` and `<KHE_ROOT>/CLAUDE.md` to `khe-meta/ESTATE.md`, so AI agents started at the umbrella root get the estate index automatically. Skipped with a note if `khe-meta` isn't cloned. See [`docs/resolution.md`](docs/resolution.md) for the layered model.
3. **Curated workflow library** - `skills/` and `agents/` will hold a small, opinionated, every-file-justified set (Phase 1.5).
4. **Snippet library** - `shared/` for per-project AGENTS.md content (Phase 3).

## Why hand-written, not forked

The AI-tooling space is under a year old. No framework is "battle-tested". The best you can do is keep your surface small enough to maintain. Frameworks bring 10× more files than you understand - most of them dead weight for your actual workflow.

This repo bets on the **standard** ([agents.md](https://agents.md/)), not any specific tool. If a tool dies, the standard moves on. If a framework dies, you're stuck.

## Inventory (every file justified)

| Path | Purpose |
|------|---------|
| `AGENTS.md` | User-level prefs, scaffold only. → `~/.codex/AGENTS.md`. Auto-read by 20+ AI tools. |
| `CLAUDE.md` | One-line `@AGENTS.md` import + Claude-only extras section. → `~/.claude/CLAUDE.md`. |
| `settings.json` | Claude Code settings. Pre-set with token-optimization defaults (`model: sonnet`, `MAX_THINKING_TOKENS=10000`, `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`). → `~/.claude/settings.json`. |
| `codex/config.toml` | OpenAI Codex CLI config, commented placeholder. → `~/.codex/config.toml`. |
| `skills/verification.md` | Run build/typecheck/test/lint and report honestly before declaring done. |
| `skills/tdd.md` | RED/GREEN/REFACTOR cycle with git checkpoints, for new features and bug fixes. |
| `skills/commit-style.md` | Conventional Commits format. Body explains WHY, not WHAT. |
| `agents/code-reviewer.md` | Second-pass reviewer with confidence filter (>80%) and severity rubric. |
| `agents/planner.md` | Plan-before-code subagent for non-trivial features and refactors. |
| `shared/` | Tech-stack snippets for per-project AGENTS.md. Empty - Phase 3. |
| `hooks/` | Claude Code hook scripts. Empty - add when you find a real problem to solve. |
| `install.ps1` / `install.sh` | Symlink files into `~/.claude/` and `~/.codex/`, plus wire up `<KHE_ROOT>/AGENTS.md` and `<KHE_ROOT>/CLAUDE.md` for umbrella-root sessions. Falls back to copy on Windows without Developer Mode. |
| `docs/resolution.md` | Reference for how `AGENTS.md` / `CLAUDE.md` are discovered and merged across user-global, umbrella, and project layers. Cited from canonical Anthropic + agents.md docs. |
| `LAST_REVIEWED.md` | Quarterly review log against upstream sources. |
| `LICENSE` | MIT. |

You should be able to read every file in this repo in 30 minutes. If you can't, something has gone wrong.

## Install

### Windows (PowerShell)

```powershell
git clone https://github.com/khelias/khe-ai-rules
cd khe-ai-rules
.\install.ps1
```

Symlinks need Developer Mode (`Settings → Privacy & security → For developers → Developer Mode`) or an admin PowerShell. Without either, the script copies files and warns you to re-run after edits.

### Unix

```bash
git clone https://github.com/khelias/khe-ai-rules
cd khe-ai-rules
./install.sh
```

## Phase plan

This repo is foundation only. Personal preferences and project-specific patterns layer in later - committed separately so you can see and roll back each layer.

| Phase | Scope |
|-------|-------|
| **1** | Pure scaffolding: structure, install scripts, AGENTS.md/CLAUDE.md/settings.json placeholders. |
| **1.5** (this commit) | Curated `skills/` (3 files) + `agents/` (2 files), reviewed file-by-file from EWC and trimmed/rewritten. Total ~425 lines, every rule justified. |
| **2** | Fill in personal preferences in `AGENTS.md` (Communication, Code style sections). |
| **3** | Extract reusable tech-stack snippets from existing project `CLAUDE.md` / `.cursor/rules/` into `shared/`. |
| **4** | Per-project migration: replace existing CLAUDE.md / .cursor/rules in project repos with thin per-project `AGENTS.md` + imports from `shared/`. |

## Staying current

The AI-tooling space changes monthly. To not fall behind:

- **Watch** the canonical sources for releases (GitHub → Watch → Releases only):
  - [agentsmd/agents.md](https://github.com/agentsmd/agents.md)
  - [anthropics/claude-code](https://github.com/anthropics/claude-code)
  - [openai/codex](https://github.com/openai/codex)
- **Quarterly review** - calendar reminder, follow checklist in [`LAST_REVIEWED.md`](LAST_REVIEWED.md).
- **Don't be early adopter** for everything - let new tools settle 3–6 months before adopting.

## Sources

This repo's structure and content come from canonical references:

- [agents.md spec](https://agents.md/) - the open standard
- [Anthropic Claude Code memory docs](https://code.claude.com/docs/en/memory) - `@import` pattern, hierarchy
- [OpenAI Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md) - Codex behavior
- [GitHub Blog: lessons from 2,500+ AGENTS.md files](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) - content guidance

Inspirational reads (consult for patterns; don't fork wholesale):

- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) - large skill/agent library. Star count is suspect; treat content as inspiration, not authority.
- [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles) - solo-dev scale dotfiles with `--claude-only` install option.
- [WE3io/ai-assistant-rules](https://github.com/WE3io/ai-assistant-rules) - single-source-of-truth pattern with parity CI.

## License

MIT - see [LICENSE](LICENSE).
