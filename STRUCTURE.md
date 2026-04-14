# Repository Structure

```
claude-skills/
├── README.md                    # Main documentation
├── CHANGELOG.md                 # Version history
├── MIGRATION.md                 # Migration guide
├── STRUCTURE.md                 # This file
├── .gitignore                   # Git ignore rules
├── run                          # Installation script
├── convert-to-skills.sh         # Command → Skill converter
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
│       └── commands/            # 23 slash commands
│           ├── api-design.md
│           ├── backend-patterns.md
│           ├── coding-standards.md
│           ├── caveman.md         # bilingual EN/FR skill in same file
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
│           ├── swift-actor-persistence.md
│           ├── swift-concurrency-6-2.md
│           ├── swift-protocol-di-testing.md
│           ├── swiftui-patterns.md
│           ├── tdd-workflow.md
│           └── verification-loop.md
│
└── opencode/                    # OpenCode package
    └── .opencode/
        ├── agents/              # 9 specialized agents (same as Claude)
        │   └── [same files as claude/agents/]
        │
        ├── commands/            # 23 slash commands (same as Claude)
        │   └── [same files as claude/commands/]
        │
        └── skills/              # 23 skills (OpenCode-specific)
            ├── api-design/
            │   └── SKILL.md
            ├── backend-patterns/
            │   └── SKILL.md
            ├── coding-standards/
            │   └── SKILL.md
            ├── caveman/
            │   └── SKILL.md       # bilingual EN/FR skill in same file
            ├── database-migrations/
            │   └── SKILL.md
            ├── deep-research/
            │   └── SKILL.md
            ├── docker-patterns/
            │   └── SKILL.md
            ├── e2e-testing/
            │   └── SKILL.md
            ├── frontend-patterns/
            │   └── SKILL.md
            ├── kotlin-coroutines-flows/
            │   └── SKILL.md
            ├── kotlin-patterns/
            │   └── SKILL.md
            ├── kotlin-testing/
            │   └── SKILL.md
            ├── nuxt4-patterns/
            │   └── SKILL.md
            ├── postgres-patterns/
            │   └── SKILL.md
            ├── python-patterns/
            │   └── SKILL.md
            ├── python-testing/
            │   └── SKILL.md
            ├── security-review/
            │   └── SKILL.md
            ├── swift-actor-persistence/
            │   └── SKILL.md
            ├── swift-concurrency-6-2/
            │   └── SKILL.md
            ├── swift-protocol-di-testing/
            │   └── SKILL.md
            ├── swiftui-patterns/
            │   └── SKILL.md
            ├── tdd-workflow/
            │   └── SKILL.md
            └── verification-loop/
                └── SKILL.md
```

## Installation Creates

### For Claude Code
```
~/.claude/agents/   → symlink to claude-skills/claude/.claude/agents/
~/.claude/commands/ → symlink to claude-skills/claude/.claude/commands/
```

### For OpenCode
```
~/.opencode/agents/   → symlink to claude-skills/opencode/.opencode/agents/
~/.opencode/commands/ → symlink to claude-skills/opencode/.opencode/commands/
~/.opencode/skills/   → symlink to claude-skills/opencode/.opencode/skills/
```

## File Counts

- **Agents**: 9 (identical for both CLIs)
- **Commands**: 23 (identical for both CLIs)
- **Skills**: 23 (OpenCode only, converted from commands)

Total: **56 skill files** across both CLIs
