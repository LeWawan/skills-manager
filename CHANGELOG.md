# Changelog

## [2.1.0] - 2026-04-14

### Fixed
- **OpenCode agent paths**: All 9 agents referenced `~/.claude/commands/*.md` instead of `~/.opencode/skills/*/SKILL.md` — skills were unreachable
- **Recursive restore**: `restore_user_files` in `run` only restored top-level files; nested user subdirectories were lost after install
- **node_modules stowed**: `managed_dirs` included `node_modules/` from local repo, causing stow to back up and restore 839+ files needlessly; now excluded via `-not -name node_modules` and `.stow-local-ignore`
- **Caveman FR section**: Cleaned up franglais in the French section while keeping technical terms in English
- **Doc accuracy**: README and STRUCTURE claimed 23 commands; actual count is 26 (3 `shape-up*` were undocumented)
- **MIGRATION.md**: Stated "all commands available as skills" — corrected to "23 of 26" (shape-up excluded)
- **convert-to-skills.sh**: Added pruning of orphan skills that no longer have a matching command
- **test_run.sh**: Fixed `set -e` incompatibility with `[[ ]] && action` patterns in backup_existing

### Added
- **Unit tests**: `test_run.sh` with 24 tests covering `managed_dirs`, `get_config_dir`, `backup_existing`, `restore_user_files` (recursive + nested), `do_install`, `do_uninstall`, and full opencode cycle
- **Root .gitignore**: OpenCode runtime artifacts (`node_modules/`, `package.json`, `package-lock.json`, `bun.lock`, `.gitignore`) properly ignored at repo level
- **`.stow-local-ignore`**: Tells stow to skip runtime artifacts in the opencode package

### Changed
- **README.md**: Corrected command count to 26, documented `shape-up*` commands, differentiated Claude/OpenCode bootstrap instructions
- **STRUCTURE.md**: Fixed tree indentation, added missing files, corrected total to 93 files

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
