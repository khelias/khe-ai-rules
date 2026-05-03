# shared/

Snippets that apply to multiple projects but not all of them. Copy into the
relevant project's `AGENTS.md` when starting/migrating a project.

## What's here

Nothing yet. **Phase 3**: extract reusable tech-stack snippets from existing
project `CLAUDE.md` / `.cursor/rules/` into here.

Likely files (eventually):

- `typescript-vite.md` — TypeScript + Vite project conventions
- `playwright.md` — Playwright test patterns
- `git-conventions.md` — branch / PR style

## Why copy, not import

Cross-repo `@`-imports work in Claude Code but **not reliably in OpenAI Codex**
(Codex resolves AGENTS.md hierarchically from git root, not arbitrary paths).
Copying into the project keeps the file self-contained for any tool.

## DRY discipline

When a snippet here changes, copy the new version into projects that use it.
With ≤5 projects, manual is fine. If you grow beyond, consider a sync script
or [knowhub](https://medium.com/@yujiisobe/introducing-knowhub-share-ai-assistant-rules-across-repos-17fb6b09c114).
