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
│       ├── agents/              # 1 specialized agent
│       │   └── code-reviewer.md
│       │
│       └── commands/            # 9 slash commands
│           ├── caveman.md       # bilingual EN/FR skill in same file; FR keeps technical English terms
│           ├── code-review.md
│           ├── pitch-create.md
│           ├── pitch-review.md
│           ├── ponytail.md
│           ├── shape-up-bet.md
│           ├── shape-up-shape.md
│           ├── shape-up.md
│           └── unslop.md
│
└── opencode/                    # OpenCode package
    └── .opencode/
        ├── agents/              # 1 specialized agent (same names as Claude)
        │   └── [same files as claude/agents/]
        │
        ├── commands/            # 9 slash commands (same names as Claude)
        │   └── [same files as claude/commands/]
        │
        ├── skills/              # 6 skills (OpenCode-specific)
        │   ├── caveman/
        │   │   └── SKILL.md       # bilingual EN/FR skill in same file; FR keeps technical English terms
        │   ├── code-review/
        │   │   └── SKILL.md
        │   ├── pitch-create/
        │   │   └── SKILL.md
        │   ├── pitch-review/
        │   │   └── SKILL.md
        │   ├── ponytail/
        │   │   └── SKILL.md
        │   └── unslop/
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

- **Agents**: 1 (identical for both CLIs)
- **Commands**: 9 per CLI
- **Skills**: 6 (OpenCode only, converted from commands)

Notes:

- OpenCode skills intentionally exclude `shape-up`, `shape-up-shape`, and `shape-up-bet`
- Total tracked instruction files: 1 Claude agent + 9 Claude commands + 1 OpenCode agent + 9 OpenCode commands + 6 OpenCode skills = **26 files**
