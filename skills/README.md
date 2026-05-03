# skills/

Reusable workflow guides the agent invokes when relevant. Each skill is a
markdown file with YAML frontmatter:

```yaml
---
name: skill-name
description: When to use this skill (one sentence — the agent matches against this)
---

[markdown body — instructions, examples, checklists]
```

## What's here

Nothing yet. **Phase 1.5**: review existing skill libraries, copy what fits
this workflow with attribution, write minimal versions for what doesn't.

## Inspiration sources (read, don't fork)

- [agents.md spec](https://agents.md/) — canonical
- [affaan-m/everything-claude-code/skills](https://github.com/affaan-m/everything-claude-code/tree/main/skills) — 182 skills as patterns library (treat as inspiration; verify quality file by file)
- [citypaul/.dotfiles](https://github.com/citypaul/.dotfiles) — solo-dev scale

## Adding a skill

1. Identify a workflow you keep correcting the agent on
2. Write a markdown file with frontmatter and concrete steps — keep under 50 lines
3. Test by invoking it; refine based on what the agent gets wrong
