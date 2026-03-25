# claude-skills

Curated collection of custom agents for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Managed with [GNU Stow](https://www.gnu.org/software/stow/) for clean symlink-based installation.

## Included Skills

| Agent | Description |
|-------|-------------|
| `code-reviewer` | Code quality, security vulnerabilities, and best practices analysis |
| `frontend-developer` | React, Vue, Angular — accessible, performant UI components |
| `typescript-pro` | Advanced type system, full-stack TS, build optimization |
| `vue-expert` | Vue 3 Composition API, Nuxt 3, reactivity patterns |

## Quick Start

```bash
git clone <repo-url> && cd claude-skills
./run
```

The interactive menu will guide you through dependency installation and setup.

### Dependencies

Installed automatically if missing (requires [Homebrew](https://brew.sh)):

- **[stow](https://www.gnu.org/software/stow/)** — symlink farm manager
- **[gum](https://github.com/charmbracelet/gum)** — interactive terminal UI

## How It Works

```
claude-skills/
  agents/                    # stow package
    .claude/
      agents/
        code-reviewer.md
        frontend-developer.md
        typescript-pro.md
        vue-expert.md
  run                        # installer script
```

Running `./run` > **Install skills** symlinks the agents into `~/.claude/agents/`, making them available globally in Claude Code.

```
~/.claude/agents/code-reviewer.md  ->  ~/Lab/claude-skills/agents/.claude/agents/code-reviewer.md
```

To remove all symlinks, run `./run` > **Uninstall skills**.

## Adding a New Skill

1. Create a new `.md` file in `agents/.claude/agents/`
2. Follow the frontmatter format:

```markdown
---
name: my-agent
description: One-line description of what this agent does.
tools: Read, Write, Edit, Bash, Glob, Grep
---

Your agent prompt here.
```

3. Re-run `./run` > **Install skills** to symlink it.
