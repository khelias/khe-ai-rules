# agents/

Specialized subagents for delegated tasks. Each agent is a markdown file with
YAML frontmatter that the main agent dispatches to.

## What's here

Nothing yet. **Phase 1.5**: review existing agent libraries, copy what fits
with attribution, write minimal versions for what doesn't.

## When to add an agent

Only when you find yourself doing the same kind of delegation repeatedly.
Subagents aren't free — each one is more context to maintain and another
prompt to keep in sync with your main rules.

## Inspiration

- [affaan-m/everything-claude-code/agents](https://github.com/affaan-m/everything-claude-code/tree/main/agents) — 48 agents as patterns library
- [Anthropic subagent docs](https://code.claude.com/docs/en/sub-agents)
