# claude-skills

Curated collection of custom agents and slash commands for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [OpenCode](https://opencode.ai). Managed with [GNU Stow](https://www.gnu.org/software/stow/) for clean symlink-based installation.

## Quick Start

```bash
git clone <repo-url> && cd claude-skills
./run
```

📚 **Documentation**: [STRUCTURE.md](STRUCTURE.md) | [MIGRATION.md](MIGRATION.md) | [CHANGELOG.md](CHANGELOG.md)

The interactive menu will guide you through:
1. Selecting your CLI (Claude Code or OpenCode)
2. Choosing to install or uninstall skills
3. Dependency installation if needed

If you already have files in managed directories (`agents/`, `commands/`), the script will offer to back them up to `~/.claude.bak/` or `~/.opencode.bak/` before installing. User files that don't conflict with repo skills are automatically restored after stow. On uninstall, the backup is fully restored.

### Dependencies

Installed automatically if missing (requires [Homebrew](https://brew.sh)):

- **[stow](https://www.gnu.org/software/stow/)** — symlink farm manager
- **[gum](https://github.com/charmbracelet/gum)** — interactive terminal UI

## Agents

Specialized sub-agents invoked automatically by Claude Code and OpenCode. Each agent bootstraps by loading relevant slash commands as context.

| Agent | Stack | Auto-loads |
|-------|-------|------------|
| `ruby-rails` | Ruby, Rails 7+, ActiveRecord | backend-patterns, database-migrations, postgres-patterns, api-design, security-review |
| `swift-ios` | Swift 6+, SwiftUI, concurrency | swift-concurrency-6-2, swiftui-patterns, swift-actor-persistence, swift-protocol-di-testing |
| `kotlin-android` | Kotlin, Jetpack Compose, coroutines | kotlin-patterns, kotlin-testing, kotlin-coroutines-flows |
| `python-data` | Python, Airflow, dbt | python-patterns, python-testing, postgres-patterns, database-migrations |
| `devops-infra` | OpenTofu, Docker, GitLab CI | docker-patterns, security-review |
| `code-reviewer` | Multi-language | security-review, coding-standards |
| `frontend-developer` | React, Vue, TypeScript | frontend-patterns, coding-standards, e2e-testing |
| `typescript-pro` | TypeScript full-stack | coding-standards, backend-patterns, api-design |
| `vue-expert` | Vue 3, Nuxt 3 | frontend-patterns, nuxt4-patterns, coding-standards, e2e-testing |

## Slash Commands

Invoke with `/command-name` in Claude Code or OpenCode.

> **Note**: For OpenCode users, these commands are also available as **Skills** in `.opencode/skills/` for on-demand loading via the `skill` tool.

### Swift / iOS

| Command | Description |
|---------|-------------|
| `/swift-concurrency-6-2` | Swift 6.2 concurrency — `@concurrent`, isolated conformances |
| `/swiftui-patterns` | SwiftUI architecture, `@Observable`, navigation, performance |
| `/swift-actor-persistence` | Thread-safe persistence with actors |
| `/swift-protocol-di-testing` | Protocol-based DI for testable Swift code |

### Kotlin / Android

| Command | Description |
|---------|-------------|
| `/kotlin-patterns` | Idiomatic Kotlin — coroutines, null safety, DSL builders |
| `/kotlin-testing` | Kotest, MockK, coroutine testing, property-based testing |
| `/kotlin-coroutines-flows` | Structured concurrency, Flow operators, StateFlow |

### Python / Data

| Command | Description |
|---------|-------------|
| `/python-patterns` | Pythonic idioms, PEP 8, type hints, best practices |
| `/python-testing` | pytest, TDD, fixtures, mocking, parametrization |

### Web / Frontend

| Command | Description |
|---------|-------------|
| `/frontend-patterns` | React, Next.js, state management, performance |
| `/nuxt4-patterns` | Nuxt 4 hydration safety, SSR-safe data fetching |
| `/coding-standards` | Universal standards for TypeScript, React, Node.js |

### Backend / API

| Command | Description |
|---------|-------------|
| `/api-design` | REST API design — resources, pagination, error responses |
| `/backend-patterns` | Backend architecture, API design, DB optimization |
| `/database-migrations` | Schema changes, rollbacks, zero-downtime deployments |
| `/postgres-patterns` | Query optimization, indexing, schema design |

### DevOps / Security

| Command | Description |
|---------|-------------|
| `/docker-patterns` | Dockerfile best practices, Compose, multi-service orchestration |
| `/security-review` | Auth, input handling, secrets, API security checklist |

### Workflow

| Command | Description |
|---------|-------------|
| `/tdd-workflow` | Test-driven development with 80%+ coverage |
| `/e2e-testing` | Playwright E2E patterns, Page Object Model, CI/CD |
| `/deep-research` | Multi-source research with citations |
| `/verification-loop` | Comprehensive verification system for Claude Code sessions |

## How It Works

```
claude-skills/
  claude/                          # Claude Code stow package
    .claude/
      agents/                      # 9 agents → ~/.claude/agents/
      commands/                    # 22 commands → ~/.claude/commands/
  opencode/                        # OpenCode stow package
    .opencode/
      agents/                      # 9 agents → ~/.opencode/agents/
      commands/                    # 22 commands → ~/.opencode/commands/
      skills/                      # 22 skills → ~/.opencode/skills/
        api-design/SKILL.md
        kotlin-patterns/SKILL.md
        security-review/SKILL.md
        ...
  run                              # installer script
  convert-to-skills.sh             # skills converter
```

Running `./run` > Select your CLI > **Install skills**:

1. Choose between **claude** or **opencode**
2. Backs up existing managed dirs to `~/.claude.bak/` or `~/.opencode.bak/` (if any real files are present)
3. Removes real dirs so stow can create clean **directory symlinks** (tree folding)
4. Stows the package — each dir becomes a single symlink to the repo
5. Restores user files from backup that don't conflict with repo skills

### For Claude Code:
```
~/.claude/agents   →  claude-skills/claude/.claude/agents/
~/.claude/commands →  claude-skills/claude/.claude/commands/
```

### For OpenCode:
```
~/.opencode/agents   →  claude-skills/opencode/.opencode/agents/
~/.opencode/commands →  claude-skills/opencode/.opencode/commands/
~/.opencode/skills   →  claude-skills/opencode/.opencode/skills/
```

Because stow uses directory symlinks, any new skill added to the repo is **instantly available** — no re-install needed.

To remove all symlinks and restore your original files: `./run` > **Uninstall skills**.

## Adding Your Own

### For Claude Code

**Agent**: Create `claude/.claude/agents/my-agent.md`:

```markdown
---
name: my-agent
description: What this agent does.
tools: Read, Write, Edit, Bash, Glob, Grep
---

## Bootstrap

Before starting any task, read and apply the patterns from these skill files:
- `~/.claude/commands/relevant-skill.md`

Your agent system prompt here.
```

**Command**: Create `claude/.claude/commands/my-command.md` with a skill prompt. Invoke with `/my-command`.

### For OpenCode

**Agent**: Create `opencode/.opencode/agents/my-agent.md`:

```markdown
---
description: What this agent does
mode: subagent
model: anthropic/claude-sonnet-4-20250514
---

Your agent system prompt here.
```

**Command**: Create `opencode/.opencode/commands/my-command.md`:

```markdown
---
description: Brief command description
agent: build
---

Your command prompt here.
```

**Skill**: Create `opencode/.opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does (1-1024 chars)
license: MIT
compatibility: opencode
---

Your skill instructions here.
```

Then re-run `./run` > **Install skills** (or just `git pull` if already installed — tree folding means new files appear automatically).

## CLI Differences

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| **Agents** | `.claude/agents/*.md` | `.opencode/agents/*.md` |
| **Commands** | `.claude/commands/*.md` | `.opencode/commands/*.md` |
| **Skills** | ❌ Not supported | ✅ `.opencode/skills/*/SKILL.md` |
| **Invocation** | Automatic by task type | `/command` or `skill` tool |
| **Compatibility** | Claude-specific | Also supports `.claude/` paths |

### Skills vs Commands (OpenCode)

- **Commands** (`/command-name`): Directly invoke a prompt template via slash command
- **Skills** (`skill` tool): On-demand loading of reusable instructions, discovered by agents

Both are included in this repo for maximum flexibility!

## Maintenance

### Updating Skills from Commands

When you add or modify commands in `claude/.claude/commands/`, you can regenerate the OpenCode skills:

```bash
./convert-to-skills.sh
```

This script automatically converts Claude commands into OpenCode SKILL.md format.

## Credits

Slash commands sourced from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by @affaan-m.
