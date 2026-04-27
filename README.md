# skills-manager

> One binary that installs the curated catalog of **Claude Code** and **OpenCode** agents, slash commands, and skills into your shell via safe, granular symlinks.

`skills-manager` is an interactive TUI that keeps the assets in this repo and the copies your CLIs consume in `~/.claude` / `~/.opencode` in sync — without ever overwriting your own files. Add an item to the repo once, pick what you want from the menu, done.

Repository: [github.com/LeWawan/skills-manager](https://github.com/LeWawan/skills-manager)

---

## Features

- **Interactive TUI** with filterable multi-select (powered by `inquire`)
- **Safe symlinks** — the installer refuses to touch files it does not own, and confirms before replacing foreign ones
- **Granular** — install everything, or cherry-pick individual agents / commands / skills
- **Dependency resolution** — selecting an agent auto-pulls the skills/commands it bootstraps from
- **`skills convert`** subcommand that regenerates OpenCode skills from the Claude command source of truth
- **Single static binary** published for Linux and macOS (x86_64 + aarch64)
- **Zero runtime dependencies** — no `gum`, no Node, no Python, no Homebrew taps

---

## Install

### One-liner (all platforms)

```bash
curl -fsSL https://raw.githubusercontent.com/LeWawan/skills-manager/main/install.sh | sh
```

The script detects your OS + arch, pulls the matching tarball from the latest [Release](https://github.com/LeWawan/skills-manager/releases), installs it to `~/.local/share/skills-manager`, and symlinks the binary into `~/.local/bin`.

For manual install (per-platform snippets, checksum verification, build from source), read **[INSTALL.md](INSTALL.md)**.

### Usage

```bash
skills-manager              # interactive menu (default)
skills-manager list claude  # debug: list every item + what the selector would show
skills-manager list opencode
skills-manager convert      # regenerate OpenCode skills from Claude commands
```

The menu walks you through:
1. Choosing your CLI (**claude** or **opencode**)
2. Picking an action: **Install** (selective), **Install all**, or **Uninstall**
3. Selecting items from a filterable list when in selective mode

Every agent, command, and skill lands as its own symlink (file for agents/commands, directory for skills). Existing user files are never overwritten — only symlinks owned by this repo are ever managed.

---

## Agents

Sub-agents invoked automatically by Claude Code and OpenCode. Claude agents bootstrap from slash commands; OpenCode agents bootstrap from skills. The `caveman` mode is shipped as a bilingual EN/FR communication skill; the French variant keeps every technical term in English.

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

Invoke with `/command-name` in Claude Code or OpenCode. Most commands are also available as OpenCode **skills** for on-demand loading via the `skill` tool. The three `shape-up*` commands remain slash-command only.

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
| `/caveman` | Ultra-compressed response mode, bilingual EN/FR in the same file |

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

---

## Repository layout

```
claude-skills/
├── claude/.claude/
│   ├── agents/                      → ~/.claude/agents/
│   └── commands/                    → ~/.claude/commands/
├── opencode/.opencode/
│   ├── agents/                      → ~/.opencode/agents/
│   ├── commands/                    → ~/.opencode/commands/
│   └── skills/                      → ~/.opencode/skills/
│       └── <name>/SKILL.md
├── src/                             # Rust source of the `skills` binary
└── Cargo.toml
```

Running `skills-manager` creates one symlink per selected item, for example:

```
~/.claude/agents/code-reviewer.md  →  skills-manager/claude/.claude/agents/code-reviewer.md
~/.opencode/skills/caveman/        →  skills-manager/opencode/.opencode/skills/caveman/
```

---

## Documentation

- [INSTALL.md](INSTALL.md) — prebuilt binaries, build from source, troubleshooting
- [CONTRIBUTING.md](CONTRIBUTING.md) — how to add your own agents, commands, and skills
- [STRUCTURE.md](STRUCTURE.md) — repository and installation layout

---

## License

MIT.

Slash commands originally sourced from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by @affaan-m.
