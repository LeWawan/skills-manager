# Migration Guide

## For Existing Claude Code Users

If you're already using this repo with Claude Code and want to try OpenCode:

### Option 1: Keep Both CLIs

You can install skills for both CLIs simultaneously:

```bash
# Install for Claude Code
./run
# Select: claude > Install skills

# Install for OpenCode  
./run
# Select: opencode > Install skills
```

Both will coexist peacefully in separate directories.

### Option 2: Migrate to OpenCode Only

1. **Uninstall Claude skills** (optional - backs up your custom files):
   ```bash
   ./run
   # Select: claude > Uninstall skills
   ```

2. **Install OpenCode skills**:
   ```bash
   ./run
   # Select: opencode > Install skills
   ```

3. Your custom agents and commands from `~/.claude/` will be backed up to `~/.claude.bak/`

## New to Both?

Just run:
```bash
./run
```

And select your preferred CLI. The script will guide you through the installation.

## What's Different in OpenCode?

### Agents
Same structure, just in `.opencode/agents/` instead of `.claude/agents/`

### Commands  
Same structure, just in `.opencode/commands/` instead of `.claude/commands/`

### Skills (New in OpenCode!)
OpenCode introduces a **Skills** system for on-demand loading:
- Located in `.opencode/skills/<name>/SKILL.md`
- Loaded via the `skill` tool when needed
- All commands are available as skills too

**Example usage in OpenCode:**
```
Can you help me review this API design?
# Agent might load the "api-design" skill automatically

Or manually:
Use the api-design skill to review my endpoints
```

## Troubleshooting

### "A backup already exists"
If you see this error, you have an existing backup. Either:
- Remove it: `rm -rf ~/.claude.bak` or `rm -rf ~/.opencode.bak`
- Or restore it manually before installing

### Symlinks not working
Make sure you're in the repo directory when running `./run`

### Skills not showing in OpenCode
- Verify the files exist: `ls ~/.opencode/skills/`
- Check SKILL.md has proper YAML frontmatter
- Restart OpenCode

## Getting Help

- [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code)
- [OpenCode docs](https://opencode.ai/docs)
- Open an issue in this repo
