# Contributing to skills-manager

Thanks for your interest! Issues and pull requests are welcome — new agents, new skills, fixes, doc improvements.

For non-trivial changes (new architecture, breaking changes), please open an issue first to discuss the approach. For bugs, typos, and small doc fixes, go straight to a PR.

## Building

```bash
git clone https://github.com/<your-user>/skills-manager.git
cd skills-manager
cargo build --release
./target/release/skills-manager
```

Requirements: Rust stable (1.79+), `git`. No other runtime dependency.

## Testing

A `justfile` ships with the repo to run the same checks as CI in one command. Install [`just`](https://github.com/casey/just) (`brew install just`), then:

```bash
just            # list available recipes
just check      # run fmt + clippy + tests (same as CI)
just fix        # auto-fix formatting and clippy lints
```

Or invoke cargo directly:

```bash
cargo fmt --all -- --check
cargo clippy --all-targets --locked -- -D warnings
cargo test --release --locked
```

End-to-end smoke test on a disposable `HOME`:

```bash
HOME=/tmp/fake-home cargo run --release
# inspect /tmp/fake-home/.claude/ and /tmp/fake-home/.opencode/
```

Dry-run inspection of what the installer sees for each CLI:

```bash
cargo run --release -- list claude
cargo run --release -- list opencode
```

## Project layout

```
src/                          Rust source (the binary itself)
claude/.claude/agents/        Claude Code agents
claude/.claude/commands/      Claude Code slash commands
opencode/.opencode/agents/    OpenCode agents
opencode/.opencode/commands/  OpenCode slash commands
opencode/.opencode/skills/    OpenCode skills (one dir per skill, with SKILL.md)
```

The binary symlinks individual files (agents/commands) and directories (skills) from this repo into `~/.claude` / `~/.opencode`. Existing user files are never overwritten — only symlinks owned by this repo are managed.

## The symmetry rule

Every item must exist on **both** sides of the repo:

```
claude/.claude/agents/<name>.md     ↔  opencode/.opencode/agents/<name>.md
claude/.claude/commands/<name>.md   ↔  opencode/.opencode/commands/<name>.md
                                       opencode/.opencode/skills/<name>/SKILL.md
```

The two formats differ slightly (frontmatter keys, skill wrapping) but the content should be equivalent. Breaking symmetry means one of the two CLIs ships a stale version.

**Exceptions:**

- `shape-up`, `shape-up-shape`, `shape-up-bet` are intentionally Claude-only (no OpenCode skill variants). They are explicitly skipped by `skills-manager convert`.
- `caveman` is intentionally bilingual (EN/FR) in the same file on both CLIs; French keeps every technical term in English.

## Adding an agent

### Claude Code agent

Create `claude/.claude/agents/my-agent.md`:

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

The `Bootstrap` block is parsed by the installer to resolve dependencies — selecting this agent in `skills-manager` will auto-install every command it references.

### OpenCode agent

Create `opencode/.opencode/agents/my-agent.md`:

```markdown
---
description: What this agent does
mode: subagent
model: anthropic/claude-sonnet-4-20250514
---

## Bootstrap

Before starting any task, read and apply the patterns from these skill files:
- `~/.opencode/skills/relevant-skill/SKILL.md`

Your agent system prompt here.
```

OpenCode bootstraps from **skills** (not commands), so reference `~/.opencode/skills/<name>/SKILL.md` paths.

## Adding a slash command

### Claude Code command

Create `claude/.claude/commands/my-command.md`:

```markdown
---
name: my-command
description: Brief command description.
---

Your command prompt here.
```

Invoke with `/my-command`.

### OpenCode command

Create `opencode/.opencode/commands/my-command.md`:

```markdown
---
description: Brief command description
agent: build
---

Your command prompt here.
```

Invoke with `/my-command`.

## Adding an OpenCode skill

Skills are discovered by agents via the `skill` tool. Create `opencode/.opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does (1–1024 chars)
license: MIT
compatibility: opencode
---

Your skill instructions here.
```

## Regenerating OpenCode skills

You should not hand-write `SKILL.md` files most of the time — they are generated from the Claude command that shares the same name. Edit the Claude command first, then regenerate:

```bash
skills-manager convert
```

This reads every `claude/.claude/commands/*.md`, writes the equivalent `opencode/.opencode/skills/<name>/SKILL.md` with the extended OpenCode frontmatter, and prunes orphan skills that no longer have a matching command. The three `shape-up*` files are skipped.

If you edited a Claude command, regenerate the OpenCode mirror and commit both:

```bash
skills-manager convert
git add claude/ opencode/
```

## CLI differences at a glance

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| Agents | `.claude/agents/*.md` | `.opencode/agents/*.md` |
| Commands | `.claude/commands/*.md` | `.opencode/commands/*.md` |
| Skills | ❌ not supported | ✅ `.opencode/skills/*/SKILL.md` |
| Invocation | Automatic by task type | `/command` or `skill` tool |
| Agent bootstrap source | Command files in `~/.claude/commands/` | Skill files in `~/.opencode/skills/` |

## Pull requests

- Keep PRs focused — one logical change per PR.
- Target `main`. Rebase rather than merge when updating your branch.
- CI must pass before review.
- Mirror your change on the other CLI when applicable (see [the symmetry rule](#the-symmetry-rule)).
- [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `chore:`, …) are appreciated for the auto-generated changelog, but not enforced.
