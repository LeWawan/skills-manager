# claude-skills

Curated collection of custom agents and slash commands for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [OpenCode](https://opencode.ai). Uses direct symlinks for clean, granular installation.

## Quick Start

### Option 1 — download a prebuilt binary

Releases are produced by `semantic-release` on every push to `main`. Using the same plugin set as `delupay-admin-web` / `merchant-web` / `delupay-fasttrack` / `delupay-static` (Conventional Commits → version bump → GitLab Release). Each release ships prebuilt binaries for Linux and macOS (x86_64 + aarch64):

```bash
# macOS Apple Silicon example — replace TAG with the version you want
curl -L -o skills.tar.gz "<gitlab-release-asset-url>"
tar xzf skills.tar.gz
chmod +x skills
# macOS may quarantine unsigned binaries on first run:
xattr -d com.apple.quarantine skills || true
./skills
```

Binaries are published to the project's GitLab Package Registry and linked from each Release page.

### Option 2 — build from source

```bash
git clone <repo-url> && cd claude-skills
cargo run --release
```

Or install the binary once and reuse it:

```bash
cargo install --path .
skills            # runs the interactive menu
```

📚 **Documentation**: [STRUCTURE.md](STRUCTURE.md) | [MIGRATION.md](MIGRATION.md) | [CHANGELOG.md](CHANGELOG.md)

The interactive menu will guide you through:
1. Selecting your CLI (Claude Code or OpenCode)
2. Choosing an action: **Install** (selective), **Install all**, or **Uninstall**
3. Picking individual items to install or remove (in selective mode)

Each agent, command, and skill is symlinked individually — your existing files are never touched. Only symlinks owned by this repo are managed.

### Requirements

- **[Rust toolchain](https://rustup.rs)** (stable). The TUI is built with `inquire` — no external binaries needed.

### CLI subcommands

```bash
skills              # interactive menu (default)
skills run          # same as above
skills list claude  # debug: list all items + visible items
skills list opencode
skills convert      # regenerate OpenCode skills from Claude commands
```

### Tests

```bash
cargo test
```

## Agents

Specialized sub-agents invoked automatically by Claude Code and OpenCode. Claude agents bootstrap from slash commands; OpenCode agents bootstrap from skills.

`caveman` is included as a bilingual English/French communication skill in the same file for both CLIs. French mode keeps technical terms in English.

| Agent | Stack | Auto-loads |
|-------|-------|------------|
| `adonisjs-backend` | AdonisJS 6, Lucid ORM, VineJS | caveman, adonisjs-backend, backend-patterns, database-migrations, postgres-patterns, api-design, security-review |
| `ruby-rails` | Ruby, Rails 7+, ActiveRecord | caveman, backend-patterns, database-migrations, postgres-patterns, api-design, security-review |
| `swift-ios` | Swift 6+, SwiftUI, concurrency | caveman, swift-concurrency-6-2, swiftui-patterns, swift-actor-persistence, swift-protocol-di-testing |
| `kotlin-android` | Kotlin, Jetpack Compose, coroutines | caveman, kotlin-patterns, kotlin-testing, kotlin-coroutines-flows |
| `python-data` | Python, Airflow, dbt | caveman, python-patterns, python-testing, postgres-patterns, database-migrations |
| `devops-infra` | OpenTofu, Docker, GitLab CI | caveman, docker-patterns, security-review |
| `code-reviewer` | Multi-language | caveman, security-review, coding-standards |
| `frontend-developer` | React, Vue, TypeScript | caveman, frontend-patterns, coding-standards, e2e-testing |
| `typescript-pro` | TypeScript full-stack | caveman, coding-standards, backend-patterns, api-design |
| `vue-expert` | Vue 3, Nuxt 3 | caveman, frontend-patterns, nuxt4-patterns, coding-standards, e2e-testing |

## Slash Commands

Invoke with `/command-name` in Claude Code or OpenCode.

> **Note**: 24 of the 27 commands are also available as OpenCode **Skills** in `.opencode/skills/` for on-demand loading via the `skill` tool. The 3 `shape-up*` commands remain slash-command only.

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
| `/caveman` | Ultra-compressed response mode, with English and French instructions in the same file. French mode keeps technical terms in English |

### Backend / API

| Command | Description |
|---------|-------------|
| `/adonisjs-backend` | AdonisJS 6 — controllers, Lucid ORM, VineJS, auth, Bouncer, Japa tests |
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

### Product / Planning

| Command | Description |
|---------|-------------|
| `/shape-up` | Full Shape Up methodology for shaping, betting, and building |
| `/shape-up-shape` | Shape raw ideas into ready-to-pitch projects |
| `/shape-up-bet` | Run betting table and choose cycle work |

## How It Works

```
claude-skills/
  claude/                          # Claude Code package
    .claude/
      agents/                      # agents → ~/.claude/agents/
      commands/                    # commands → ~/.claude/commands/
  opencode/                        # OpenCode package
    .opencode/
      agents/                      # agents → ~/.opencode/agents/
      commands/                    # commands → ~/.opencode/commands/
      skills/                      # skills → ~/.opencode/skills/
        api-design/SKILL.md
        kotlin-patterns/SKILL.md
        security-review/SKILL.md
        ...
  src/                             # Rust source
    main.rs                        # clap dispatch
    item.rs                        # Item + path resolution
    discovery.rs                   # list_all, desc_of, deps_of, list_visible
    link.rs                        # symlink, migrate, unfold
    ui.rs                          # inquire-based TUI
    convert.rs                     # Claude commands → OpenCode skills
  Cargo.toml
```

Running `skills`:

1. Choose between **claude** or **opencode**
2. Pick an action: **Install** (selective), **Install all**, or **Uninstall**
3. For selective install/uninstall, pick individual items from a filterable list
4. Each item is symlinked individually (file → file, skill dir → dir)
5. Existing user files are never overwritten — only our own symlinks are managed

### For Claude Code:
```
~/.claude/agents/agent-name.md   →  claude-skills/claude/.claude/agents/agent-name.md
~/.claude/commands/cmd-name.md   →  claude-skills/claude/.claude/commands/cmd-name.md
```

### For OpenCode:
```
~/.opencode/agents/agent-name.md   →  claude-skills/opencode/.opencode/agents/agent-name.md
~/.opencode/commands/cmd-name.md   →  claude-skills/opencode/.opencode/commands/cmd-name.md
~/.opencode/skills/skill-name/     →  claude-skills/opencode/.opencode/skills/skill-name/
```

New items added to the repo require re-running `skills` to install them.

To remove symlinks: `skills` > **Uninstall** > select items to remove.

## Adding Your Own

> **Symmetry rule**: Every agent, command, or skill must exist on **both** the Claude Code side (`claude/.claude/`) and the OpenCode side (`opencode/.opencode/`). When adding a new item, always create the equivalent in both packages to keep the two CLIs in sync. The formats differ slightly (frontmatter, skill structure) but the content should be the same.

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

Then re-run `skills` > **Install** or **Install all** to pick up new items.

## CLI Differences

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| **Agents** | `.claude/agents/*.md` | `.opencode/agents/*.md` |
| **Commands** | `.claude/commands/*.md` | `.opencode/commands/*.md` |
| **Skills** | ❌ Not supported | ✅ `.opencode/skills/*/SKILL.md` |
| **Invocation** | Automatic by task type | `/command` or `skill` tool |
| **Agent bootstrap** | Command files in `~/.claude/commands/` | Skill files in `~/.opencode/skills/` |

### Skills vs Commands (OpenCode)

- **Commands** (`/command-name`): Directly invoke a prompt template via slash command
- **Skills** (`skill` tool): On-demand loading of reusable instructions, discovered by agents

Both are included in this repo for maximum flexibility!

## Maintenance

### Updating Skills from Commands

When you add or modify commands in `claude/.claude/commands/`, you can regenerate the OpenCode skills:

```bash
skills convert
```

This subcommand converts Claude commands into OpenCode `SKILL.md` format.

Current exception: `shape-up`, `shape-up-shape`, and `shape-up-bet` are intentionally skipped by the converter.

Note: `caveman` is maintained as a bilingual EN/FR skill in the same file for both command and SKILL variants. French mode keeps technical terms in English.

## Credits

Slash commands sourced from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by @affaan-m.
