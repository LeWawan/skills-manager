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
| `code-reviewer` | Multi-language | caveman |

## Slash Commands

Invoke with `/command-name` in Claude Code or OpenCode. Most commands are also available as OpenCode **skills** for on-demand loading via the `skill` tool. The three `shape-up*` commands remain slash-command only.

### Modes

| Command | Description |
|---------|-------------|
| `/caveman` | Ultra-compressed response mode, bilingual EN/FR in the same file |
| `/ponytail` | Laziest working solution — YAGNI, reuse before writing, shortest diff |
| `/unslop` | Cut AI tells from any writing |

### Code review

| Command | Description |
|---------|-------------|
| `/code-review` | Two-axis diff review (Standards + Spec) via parallel sub-agents |

### Product / Planning

| Command | Description |
|---------|-------------|
| `/shape-up` | Full Shape Up methodology for shaping, betting, and building |
| `/shape-up-shape` | Shape raw ideas into ready-to-pitch projects |
| `/shape-up-bet` | Run betting table and choose cycle work |
| `/pitch-create` | Guide the creation of a Shape Up pitch from a raw idea |
| `/pitch-review` | Gatekeep a written pitch before the betting table |

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
