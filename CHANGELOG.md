# Changelog

## [2.0.0] - 2026-04-07

### Added
- **OpenCode Support**: Full support for OpenCode CLI alongside Claude Code
- **Skills System**: Added OpenCode skills in `.opencode/skills/*/SKILL.md` format
- **Dual CLI Installation**: Interactive menu to choose between Claude Code and OpenCode
- **Conversion Script**: `convert-to-skills.sh` to automatically convert commands to OpenCode skills
- **Multi-CLI Documentation**: Updated README with CLI-specific instructions and comparison table

### Changed
- **Installation Script**: Enhanced `run` script to support both CLIs with dynamic configuration
- **Backup System**: CLI-specific backups (`.claude.bak/` or `.opencode.bak/`)
- **Directory Structure**: Added `opencode/` package parallel to `claude/`

### Technical Details
- OpenCode structure: `.opencode/{agents,commands,skills}/`
- Skills format: Each skill in `<name>/SKILL.md` with YAML frontmatter
- Maintained backward compatibility with Claude Code structure
- Both CLIs share the same skill content with appropriate formatting

## [1.0.0] - 2025-03-25

### Initial Release
- Custom agents for Claude Code (9 agents)
- Slash commands (22 commands)
- Stow-based installation system
- Automatic backup and restore functionality
