# Migration Guide

## From v2.1 (stow-based) to v3.0 (direct symlinks)

The installer no longer uses GNU Stow. It creates individual symlinks per file/skill instead of directory-level symlinks.

### What changed

- **No more stow dependency** — the installer is a self-contained Rust binary (no external runtime deps)
- **No backup/restore** — user files are never overwritten; only our own symlinks are managed
- **Granular selection** — pick individual agents, commands, and skills-manager to install
- **"Install all" option** — install everything at once without selection

### Upgrading

1. **Uninstall the old way first** (if currently installed via stow):
   ```bash
   git stash   # if you have local changes
   git checkout main
   skills-manager       # Select CLI > Uninstall skills-manager
   ```

2. **Switch to the new branch and install**:
   ```bash
   git checkout feat/drop-stow-direct-symlinks  # or main once merged
   skills-manager       # Select CLI > Install all (or Install for selective)
   ```

3. **Verify**: check that your items are symlinked:
   ```bash
   ls -la ~/.claude/agents/      # should show symlinks → repo
   ls -la ~/.opencode/skills-manager/    # should show symlinks → repo
   ```

## For Existing Claude Code Users

If you're already using this repo with Claude Code and want to try OpenCode:

### Option 1: Keep Both CLIs

You can install for both CLIs simultaneously:

```bash
skills-manager   # Select: claude > Install all
skills-manager   # Select: opencode > Install all
```

Both coexist peacefully in separate directories.

### Option 2: Migrate to OpenCode Only

1. **Uninstall Claude items**:
   ```bash
   skills-manager   # Select: claude > Uninstall > select all
   ```

2. **Install OpenCode items**:
   ```bash
   skills-manager   # Select: opencode > Install all
   ```

## New to Both?

Just run:
```bash
skills-manager
```

Select your preferred CLI. The script will guide you through installation.

## What's Different in OpenCode?

### Agents
Same structure, just in `.opencode/agents/` instead of `.claude/agents/`

### Commands
Same structure, just in `.opencode/commands/` instead of `.claude/commands/`

### Skills (New in OpenCode!)
OpenCode introduces a **Skills** system for on-demand loading:
- Located in `.opencode/skills-manager/<name>/SKILL.md`
- Loaded via the `skill` tool when needed
- 23 of the 26 commands are available as skills-manager (the 3 `shape-up*` commands remain slash-command only)

**Example usage in OpenCode:**
```
Can you help me review this API design?
# Agent might load the "api-design" skill automatically

Or manually:
Use the api-design skill to review my endpoints
```

## Troubleshooting

### Symlinks not working
Make sure you're running `skills-manager` (or `cargo run`) from the repo directory — paths are resolved relative to the current working dir.

### Item skipped during install
If you see "Skip — already exists (not ours)", there's already a file at that path that isn't one of our symlinks. Remove or rename it manually, then re-run.

### Skills not showing in OpenCode
- Verify the symlinks exist: `ls -la ~/.opencode/skills-manager/`
- Check SKILL.md has proper YAML frontmatter
- Restart OpenCode

## Getting Help

- [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code)
- [OpenCode docs](https://opencode.ai/docs)
- Open an issue in this repo
