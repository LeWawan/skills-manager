# Contributing

This repo is the single source of truth for every agent, slash command, and skill we distribute to **Claude Code** and **OpenCode**. Every change ships to both CLIs; the installer (`skills`) keeps `~/.claude` and `~/.opencode` in sync via symlinks.

## Table of contents

- [The symmetry rule](#the-symmetry-rule)
- [Adding an agent](#adding-an-agent)
  - [Claude Code agent](#claude-code-agent)
  - [OpenCode agent](#opencode-agent)
- [Adding a slash command](#adding-a-slash-command)
  - [Claude Code command](#claude-code-command)
  - [OpenCode command](#opencode-command)
- [Adding an OpenCode skill](#adding-an-opencode-skill)
- [Regenerating OpenCode skills](#regenerating-opencode-skills)
- [CLI differences at a glance](#cli-differences-at-a-glance)
- [Testing your change](#testing-your-change)
- [Release process](#release-process)

---

## The symmetry rule

Every item must exist on **both** sides of the repo:

```
claude/.claude/agents/<name>.md           ↔   opencode/.opencode/agents/<name>.md
claude/.claude/commands/<name>.md         ↔   opencode/.opencode/commands/<name>.md
                                              opencode/.opencode/skills/<name>/SKILL.md
```

The two formats differ slightly (frontmatter keys, skill wrapping) but the content should be equivalent. Breaking symmetry means one of the two CLIs is shipping a stale version — avoid it.

**Exceptions:**

- `shape-up`, `shape-up-shape`, `shape-up-bet` are intentionally Claude-only (no OpenCode skill variants). They are explicitly skipped by `skills-manager convert`.
- `caveman` is intentionally bilingual (EN/FR) in the same file on both CLIs; French keeps every technical term in English.

---

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

---

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

---

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

---

## Regenerating OpenCode skills

Most of the time you should not hand-write `SKILL.md` files — they are generated from the Claude command that shares the same name. Edit the Claude command first, then regenerate:

```bash
skills-manager convert
```

This reads every `claude/.claude/commands/*.md`, writes the equivalent `opencode/.opencode/skills/<name>/SKILL.md` with the extended OpenCode frontmatter, and prunes orphan skills that no longer have a matching command. The three `shape-up*` files are skipped.

---

## CLI differences at a glance

| Feature | Claude Code | OpenCode |
|---------|-------------|----------|
| Agents | `.claude/agents/*.md` | `.opencode/agents/*.md` |
| Commands | `.claude/commands/*.md` | `.opencode/commands/*.md` |
| Skills | ❌ not supported | ✅ `.opencode/skills/*/SKILL.md` |
| Invocation | Automatic by task type | `/command` or `skill` tool |
| Agent bootstrap source | Command files in `~/.claude/commands/` | Skill files in `~/.opencode/skills/` |

### Skills vs Commands in OpenCode

- **Commands** (`/command-name`): directly invoke a prompt template via slash command
- **Skills** (`skill` tool): on-demand loading of reusable instructions, discovered by agents

Both are published for maximum flexibility.

---

## Testing your change

After adding or editing files:

```bash
# Unit tests for the installer
cargo test

# Dry-run: show what the installer would see for each CLI
skills-manager list claude
skills-manager list opencode

# Try the flow end-to-end on a disposable target
HOME=/tmp/fake-home skills-manager   # installs into /tmp/fake-home/.claude etc.
```

If you edited a Claude command, regenerate the OpenCode mirror and commit both:

```bash
skills-manager convert
git add claude/ opencode/
```

---

## Release process

Releases are driven by [semantic-release](https://semantic-release.gitbook.io/) on every push to `main`. Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat: …` → minor version bump
- `fix: …` → patch version bump
- `feat!: …` or a `BREAKING CHANGE:` footer → major bump
- `chore: …`, `docs: …`, `ci: …`, `refactor: …`, etc. → patch bump (keeps every change trackable)

Semantic-release creates the tag, the GitLab Release, and the changelog. The CI pipeline then cross-compiles four binaries, uploads them to the Generic Package Registry, and attaches them as Release assets with an auto-generated install section. No manual tagging needed.
