# Changelog

## [3.0.0] - 2026-04-15

### Breaking Changes
- **Dropped GNU Stow**: Replaced stow-based directory symlinks with direct per-file/per-skill symlinks. Stow is no longer a dependency.
- **No backup/restore system**: User files are never overwritten — only symlinks owned by this repo are managed. The old backup/restore flow is removed.

### Added
- **"Install all" action**: New menu option to install every item at once without going through the selection filter
- **Granular selection**: Pick individual agents, commands, and skills to install or uninstall via `gum filter --no-limit`
- **Pre-selection**: Already-installed items are pre-selected when opening the install filter
- **`is_ours` safety check**: Every operation verifies the symlink points to this repo before touching it
- **Agent dependency resolution**: Selecting an agent auto-installs its referenced commands/skills from the Bootstrap section
- **Dep count in selector**: Agents show `[+N deps]` suffix in the gum filter so you know what gets bundled
- **Smart dep hiding**: Stack-specific deps (e.g. `swift-concurrency-6-2`, `kotlin-patterns`) are hidden from the selector — they install only via their agent. Universally useful items (`caveman`, `coding-standards`, `security-review`, `docker-patterns`, `tdd-workflow`, `verification-loop`, `deep-research`) remain individually selectable

### Changed
- **`run` script**: Rewritten from 209 to ~165 lines — simpler, no backup logic, no stow edge cases
- **`test_run.sh`**: Rewritten with 59 tests covering all functions including `deps_of`, dependency resolution, and `list_visible` filtering

### Removed
- **`opencode/.stow-local-ignore`**: No longer needed (stow removed)
- **stow dependency**: Only `gum` is required

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
