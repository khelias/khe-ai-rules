# Personal AGENTS.md

User-level instructions for AI coding agents. Auto-loaded by:

- OpenAI Codex CLI (this file via `~/.codex/AGENTS.md`)
- Claude Code (via `~/.claude/CLAUDE.md`, which `@`-imports this file)
- Cursor, Aider, Copilot, and 20+ other AGENTS.md-aware tools

This file holds **personal preferences** that apply to every project.
For project-specific instructions, use a per-project `AGENTS.md`.

Keep this file under 200 lines. It's loaded into every session — bigger files cost tokens forever.

---

## Communication

<!-- Phase 2: language, tone, response length, formatting preferences -->

## Code style — universal preferences

<!-- Phase 2: principles that apply across all languages
e.g., naming, comment philosophy, error handling discipline -->

## Verification

The agent MUST verify changes before declaring done:

- Run the project's test command
- Run the project's typecheck/lint command
- For UI changes, verify in a running browser if a dev server is available
- Report verification results explicitly — successes AND failures

If verification can't be performed in this environment, say so. Do not claim success.

## Boundaries

### Always

- Read existing code before editing
- Prefer editing existing files over creating new ones
- Verify changes before declaring done

### Ask first

- Destructive operations (`rm -rf`, `git reset --hard`, dropping tables, force-push)
- Rewriting published commits
- Adding new dependencies
- Changes to CI/CD pipelines

### Never

- Skip git hooks (`--no-verify`)
- Commit secrets, `.env` files, credentials
- Add unrequested documentation files (READMEs, CHANGELOGs)
- Add comments explaining WHAT code does — only WHY when non-obvious

## File hygiene

- Don't leave half-finished code or commented-out blocks
- Don't add features beyond the task scope
- Don't introduce abstractions for hypothetical future needs

---

## What goes elsewhere

- **Project-specific commands and architecture** → that project's `AGENTS.md`
- **Tech-stack patterns** (TypeScript, Playwright, etc.) → `shared/*.md`, copied into project AGENTS.md
- **Workflow recipes** (TDD loop, verification, commit style) → `skills/*.md`
- **Specialized review/planning tasks** → `agents/*.md` (delegate via subagent)
- **Claude Code hook scripts** → `hooks/*.{sh,js}`
- **Claude-specific imports/extensions** → `CLAUDE.md`
