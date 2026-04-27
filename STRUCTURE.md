# Repository Structure

```
claude-skills/
├── README.md                    # Main documentation
├── STRUCTURE.md                 # This file
├── .gitignore                   # Git ignore rules
├── Cargo.toml                   # Rust crate manifest (binary: `skills-manager`)
├── Cargo.lock
├── src/                         # Rust source — replaces run/convert-to-skills.sh/test_run.sh
│   ├── main.rs                  # clap dispatch
│   ├── item.rs                  # Item + src_path/dest_path
│   ├── discovery.rs             # list_all, desc_of, deps_of, list_visible
│   ├── link.rs                  # symlink, migrate, unfold
│   ├── ui.rs                    # inquire-based TUI
│   ├── convert.rs               # Claude commands → OpenCode skills
│   └── test_fixtures.rs         # test helpers (cfg(test) only)
│
├── claude/                      # Claude Code package
│   └── .claude/
│       ├── agents/              # 9 specialized agents
│       │   ├── code-reviewer.md
│       │   ├── devops-infra.md
│       │   ├── frontend-developer.md
│       │   ├── kotlin-android.md
│       │   ├── python-data.md
│       │   ├── ruby-rails.md
│       │   ├── swift-ios.md
│       │   ├── typescript-pro.md
│       │   └── vue-expert.md
│       │
│       └── commands/            # 26 slash commands
│           ├── api-design.md
│           ├── backend-patterns.md
│           ├── coding-standards.md
│           ├── caveman.md       # bilingual EN/FR skill in same file; FR keeps technical English terms
│           ├── database-migrations.md
│           ├── deep-research.md
│           ├── docker-patterns.md
│           ├── e2e-testing.md
│           ├── frontend-patterns.md
│           ├── kotlin-coroutines-flows.md
│           ├── kotlin-patterns.md
│           ├── kotlin-testing.md
│           ├── nuxt4-patterns.md
│           ├── postgres-patterns.md
│           ├── python-patterns.md
│           ├── python-testing.md
│           ├── security-review.md
│           ├── shape-up-bet.md
│           ├── shape-up-shape.md
│           ├── shape-up.md
│           ├── swift-actor-persistence.md
│           ├── swift-concurrency-6-2.md
│           ├── swift-protocol-di-testing.md
│           ├── swiftui-patterns.md
│           ├── tdd-workflow.md
│           └── verification-loop.md
│
└── opencode/                    # OpenCode package
    └── .opencode/
        ├── agents/              # 9 specialized agents (same names as Claude)
        │   └── [same files as claude/agents/]
        │
        ├── commands/            # 26 slash commands (same names as Claude)
        │   └── [same files as claude/commands/]
        │
        ├── skills/              # 23 skills (OpenCode-specific)
        │   ├── api-design/
        │   │   └── SKILL.md
        │   ├── backend-patterns/
        │   │   └── SKILL.md
        │   ├── coding-standards/
        │   │   └── SKILL.md
        │   ├── caveman/
        │   │   └── SKILL.md       # bilingual EN/FR skill in same file; FR keeps technical English terms
        │   ├── database-migrations/
        │   │   └── SKILL.md
        │   ├── deep-research/
        │   │   └── SKILL.md
        │   ├── docker-patterns/
        │   │   └── SKILL.md
        │   ├── e2e-testing/
        │   │   └── SKILL.md
        │   ├── frontend-patterns/
        │   │   └── SKILL.md
        │   ├── kotlin-coroutines-flows/
        │   │   └── SKILL.md
        │   ├── kotlin-patterns/
        │   │   └── SKILL.md
        │   ├── kotlin-testing/
        │   │   └── SKILL.md
        │   ├── nuxt4-patterns/
        │   │   └── SKILL.md
        │   ├── postgres-patterns/
        │   │   └── SKILL.md
        │   ├── python-patterns/
        │   │   └── SKILL.md
        │   ├── python-testing/
        │   │   └── SKILL.md
        │   ├── security-review/
        │   │   └── SKILL.md
        │   ├── swift-actor-persistence/
        │   │   └── SKILL.md
        │   ├── swift-concurrency-6-2/
        │   │   └── SKILL.md
        │   ├── swift-protocol-di-testing/
        │   │   └── SKILL.md
        │   ├── swiftui-patterns/
        │   │   └── SKILL.md
        │   ├── tdd-workflow/
        │   │   └── SKILL.md
        │   └── verification-loop/
        │       └── SKILL.md
        └── (node_modules/, package.json — runtime artifacts, git-ignored)
```

## Installation Creates

Each item is symlinked individually (file-level for agents/commands, directory-level for skills).

### For Claude Code
```
~/.claude/agents/agent-name.md   → claude-skills/claude/.claude/agents/agent-name.md
~/.claude/commands/cmd-name.md   → claude-skills/claude/.claude/commands/cmd-name.md
```

### For OpenCode
```
~/.opencode/agents/agent-name.md   → claude-skills/opencode/.opencode/agents/agent-name.md
~/.opencode/commands/cmd-name.md   → claude-skills/opencode/.opencode/commands/cmd-name.md
~/.opencode/skills/skill-name/     → claude-skills/opencode/.opencode/skills/skill-name/
```

## File Counts

- **Agents**: 9 (identical for both CLIs)
- **Commands**: 26 per CLI
- **Skills**: 23 (OpenCode only, converted from commands)

Notes:

- OpenCode skills intentionally exclude `shape-up`, `shape-up-shape`, and `shape-up-bet`
- Total tracked instruction files: 9 Claude agents + 26 Claude commands + 9 OpenCode agents + 26 OpenCode commands + 23 OpenCode skills = **93 files**
