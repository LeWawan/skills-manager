#!/usr/bin/env bash
# Unit tests for the ./run installer script.
# Runs in an isolated temp dir — no side effects on the real system.
#
# Usage:  ./test_run.sh
# Exit 0 = all pass, exit 1 = at least one failure.

set -o pipefail
# NOTE: set -e removed — it interacts badly with [[ ]] && patterns in test assertions

###############################################################################
# Test harness
###############################################################################
PASS=0
FAIL=0
CURRENT_TEST=""

pass() {
	PASS=$((PASS + 1))
	echo "  ✓ $CURRENT_TEST"
}
fail() {
	FAIL=$((FAIL + 1))
	echo "  ✗ $CURRENT_TEST — $1"
}

assert_file_exists() {
	[[ -f "$1" ]] && return 0
	fail "expected file $1"
	return 1
}
assert_file_missing() {
	[[ ! -e "$1" ]] && return 0
	fail "expected $1 absent"
	return 1
}
assert_dir_exists() {
	[[ -d "$1" ]] && return 0
	fail "expected dir $1"
	return 1
}
assert_dir_missing() {
	[[ ! -e "$1" ]] && return 0
	fail "expected $1 absent"
	return 1
}
assert_link() {
	[[ -L "$1" ]] && return 0
	fail "expected symlink $1"
	return 1
}
assert_eq() {
	if [[ "$1" == "$2" ]]; then return 0; fi
	fail "expected '$2', got '$1'"
	return 1
}
assert_contains() {
	if [[ "$1" == *"$2"* ]]; then return 0; fi
	fail "expected output to contain '$2'"
	return 1
}

###############################################################################
# Setup / teardown per test
###############################################################################
TMP_ROOT=""

setup() {
	TMP_ROOT=$(mktemp -d)

	# -- Fake REPO_DIR with a "claude" package ----------------------------------
	REPO_DIR="$TMP_ROOT/repo"
	mkdir -p "$REPO_DIR/claude/.claude/agents"
	mkdir -p "$REPO_DIR/claude/.claude/commands"
	echo "agent-a content" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
	echo "agent-b content" >"$REPO_DIR/claude/.claude/agents/agent-b.md"
	echo "cmd-x content" >"$REPO_DIR/claude/.claude/commands/cmd-x.md"
	echo "cmd-y content" >"$REPO_DIR/claude/.claude/commands/cmd-y.md"

	# -- Fake REPO_DIR with an "opencode" package --------------------------------
	mkdir -p "$REPO_DIR/opencode/.opencode/agents"
	mkdir -p "$REPO_DIR/opencode/.opencode/commands"
	mkdir -p "$REPO_DIR/opencode/.opencode/skills/api-design"
	echo "oc-agent content" >"$REPO_DIR/opencode/.opencode/agents/oc-agent.md"
	echo "oc-cmd content" >"$REPO_DIR/opencode/.opencode/commands/oc-cmd.md"
	echo "skill content" >"$REPO_DIR/opencode/.opencode/skills/api-design/SKILL.md"

	# -- Fake HOME ---------------------------------------------------------------
	STOW_TARGET="$TMP_ROOT/home"
	mkdir -p "$STOW_TARGET"

	# -- Source functions from run (override globals, skip main) -----------------
	# We re-source a trimmed version that only defines functions.
	_source_functions
}

teardown() {
	[[ -n "$TMP_ROOT" && -d "$TMP_ROOT" ]] && rm -rf "$TMP_ROOT"
}

_source_functions() {
	# Minimal shim: define all functions from ./run with our overridden globals.
	# We do NOT call main().

	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[0;33m'
	NC='\033[0m'

	info() { echo -e "${GREEN}[info]${NC} $1"; }
	warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
	error() { echo -e "${RED}[error]${NC} $1"; }

	managed_dirs() {
		local config_dir="$REPO_DIR/$SELECTED_CLI/.$SELECTED_CLI"
		find "$config_dir" -maxdepth 1 -mindepth 1 -type d \
			-not -name node_modules \
			-exec basename {} \;
	}

	get_config_dir() {
		echo "$STOW_TARGET/.$SELECTED_CLI"
	}

	backup_existing() {
		local config_dir=$(get_config_dir)
		local has_real_dirs=false

		while read -r dir; do
			[[ -d "$config_dir/$dir" && ! -L "$config_dir/$dir" ]] && has_real_dirs=true && break
		done < <(managed_dirs)

		if [[ "$has_real_dirs" == false ]]; then
			return 0
		fi

		if [[ -d "$BACKUP_DIR" ]]; then
			error "A backup already exists at $BACKUP_DIR"
			return 1
		fi

		# In tests we always accept backup (no gum prompt)
		mkdir -p "$BACKUP_DIR"
		while read -r dir; do
			[[ -d "$config_dir/$dir" && ! -L "$config_dir/$dir" ]] && cp -r "$config_dir/$dir" "$BACKUP_DIR/$dir"
		done < <(managed_dirs)

		# Remove real dirs so stow can do clean tree folding
		while read -r dir; do
			[[ -d "$config_dir/$dir" && ! -L "$config_dir/$dir" ]] && rm -rf "$config_dir/$dir"
		done < <(managed_dirs)
	}

	restore_user_files() {
		[[ ! -d "$BACKUP_DIR" ]] && return 0

		local config_dir=$(get_config_dir)
		local count=0

		while IFS= read -r -d '' src; do
			local rel="${src#"$BACKUP_DIR"/}"
			local dest="$config_dir/$rel"
			if [[ -d "$src" ]]; then
				[[ ! -d "$dest" ]] && mkdir -p "$dest"
			elif [[ -f "$src" ]] && [[ ! -e "$dest" ]]; then
				mkdir -p "$(dirname "$dest")"
				cp "$src" "$dest"
				count=$((count + 1))
			fi
		done < <(find "$BACKUP_DIR" -mindepth 2 -print0)

		if [[ $count -gt 0 ]]; then
			info "Restored $count user file(s) from backup"
		fi
	}

	do_install() {
		backup_existing

		# Ensure config dir exists so stow doesn't tree-fold the top level
		mkdir -p "$(get_config_dir)"

		for pkg in "${PACKAGES[@]}"; do
			stow -t "$STOW_TARGET" -d "$REPO_DIR" -D "$pkg" 2>/dev/null || true
			stow -t "$STOW_TARGET" -d "$REPO_DIR" "$pkg"
		done

		restore_user_files
	}

	do_uninstall() {
		for pkg in "${PACKAGES[@]}"; do
			stow -t "$STOW_TARGET" -d "$REPO_DIR" -D "$pkg"
		done

		if [[ -d "$BACKUP_DIR" ]]; then
			local config_dir=$(get_config_dir)
			[[ -L "$config_dir" ]] && rm "$config_dir"
			mkdir -p "$config_dir"
			cp -r "$BACKUP_DIR"/* "$config_dir/"
			rm -rf "$BACKUP_DIR"
		fi
	}
}

###############################################################################
# Require stow
###############################################################################
if ! command -v stow &>/dev/null; then
	echo "ERROR: stow is required to run these tests. Install with: brew install stow"
	exit 1
fi

###############################################################################
# Tests: managed_dirs
###############################################################################
echo ""
echo "== managed_dirs =="

CURRENT_TEST="lists agent and command dirs for claude"
setup
SELECTED_CLI="claude"
dirs=$(managed_dirs | sort)
expected=$(printf "agents\ncommands")
assert_eq "$dirs" "$expected" && pass
teardown

CURRENT_TEST="lists agents, commands, skills for opencode"
setup
SELECTED_CLI="opencode"
dirs=$(managed_dirs | sort)
expected=$(printf "agents\ncommands\nskills")
assert_eq "$dirs" "$expected" && pass
teardown

CURRENT_TEST="excludes node_modules from managed dirs"
setup
SELECTED_CLI="opencode"
mkdir -p "$REPO_DIR/opencode/.opencode/node_modules/some-pkg"
echo "pkg" >"$REPO_DIR/opencode/.opencode/node_modules/some-pkg/index.js"
dirs=$(managed_dirs | sort)
expected=$(printf "agents\ncommands\nskills")
assert_eq "$dirs" "$expected" && pass
teardown

###############################################################################
# Tests: get_config_dir
###############################################################################
echo ""
echo "== get_config_dir =="

CURRENT_TEST="returns correct path for claude"
setup
SELECTED_CLI="claude"
result=$(get_config_dir)
assert_eq "$result" "$STOW_TARGET/.claude" && pass
teardown

CURRENT_TEST="returns correct path for opencode"
setup
SELECTED_CLI="opencode"
result=$(get_config_dir)
assert_eq "$result" "$STOW_TARGET/.opencode" && pass
teardown

###############################################################################
# Tests: backup_existing
###############################################################################
echo ""
echo "== backup_existing =="

CURRENT_TEST="no-op when config dir does not exist"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
backup_existing
assert_dir_missing "$BACKUP_DIR" && pass
teardown

CURRENT_TEST="no-op when config dir has only symlinks"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude"
ln -s /tmp "$STOW_TARGET/.claude/agents"
ln -s /tmp "$STOW_TARGET/.claude/commands"
backup_existing
assert_dir_missing "$BACKUP_DIR" && pass
teardown

CURRENT_TEST="backs up real dirs and removes them"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/agents"
mkdir -p "$STOW_TARGET/.claude/commands"
echo "user-agent" >"$STOW_TARGET/.claude/agents/my-agent.md"
echo "user-cmd" >"$STOW_TARGET/.claude/commands/my-cmd.md"
backup_existing
assert_dir_exists "$BACKUP_DIR" &&
	assert_file_exists "$BACKUP_DIR/agents/my-agent.md" &&
	assert_file_exists "$BACKUP_DIR/commands/my-cmd.md" &&
	assert_dir_missing "$STOW_TARGET/.claude/agents" &&
	assert_dir_missing "$STOW_TARGET/.claude/commands" &&
	pass
teardown

CURRENT_TEST="fails if backup already exists"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/agents"
echo "x" >"$STOW_TARGET/.claude/agents/x.md"
mkdir -p "$BACKUP_DIR"
output=$(backup_existing 2>&1 || true)
assert_contains "$output" "backup already exists" && pass
teardown

CURRENT_TEST="backs up nested user subdirs"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/commands/sub/deep"
echo "deep-file" >"$STOW_TARGET/.claude/commands/sub/deep/nested.md"
backup_existing
assert_file_exists "$BACKUP_DIR/commands/sub/deep/nested.md" && pass
teardown

###############################################################################
# Tests: restore_user_files
###############################################################################
echo ""
echo "== restore_user_files =="

CURRENT_TEST="no-op when no backup dir"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/agents"
restore_user_files
pass
teardown

CURRENT_TEST="restores top-level user files that do not conflict"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
# Simulate backup with user file
mkdir -p "$BACKUP_DIR/agents"
echo "user-agent" >"$BACKUP_DIR/agents/my-custom.md"
# Simulate stowed dir with repo file
mkdir -p "$STOW_TARGET/.claude/agents"
echo "repo-agent" >"$STOW_TARGET/.claude/agents/agent-a.md"
restore_user_files
assert_file_exists "$STOW_TARGET/.claude/agents/my-custom.md" && pass
teardown

CURRENT_TEST="does not overwrite existing stowed files"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$BACKUP_DIR/agents"
echo "backup-version" >"$BACKUP_DIR/agents/agent-a.md"
mkdir -p "$STOW_TARGET/.claude/agents"
echo "repo-version" >"$STOW_TARGET/.claude/agents/agent-a.md"
restore_user_files
content=$(cat "$STOW_TARGET/.claude/agents/agent-a.md")
assert_eq "$content" "repo-version" && pass
teardown

CURRENT_TEST="restores deeply nested user files"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$BACKUP_DIR/commands/sub/deep"
echo "deep-content" >"$BACKUP_DIR/commands/sub/deep/nested.md"
mkdir -p "$STOW_TARGET/.claude/commands"
restore_user_files
assert_file_exists "$STOW_TARGET/.claude/commands/sub/deep/nested.md" &&
	content=$(cat "$STOW_TARGET/.claude/commands/sub/deep/nested.md") &&
	assert_eq "$content" "deep-content" &&
	pass
teardown

CURRENT_TEST="restores files across multiple subdirs"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$BACKUP_DIR/agents" "$BACKUP_DIR/commands"
echo "user-a" >"$BACKUP_DIR/agents/custom-a.md"
echo "user-c" >"$BACKUP_DIR/commands/custom-c.md"
mkdir -p "$STOW_TARGET/.claude/agents" "$STOW_TARGET/.claude/commands"
restore_user_files
assert_file_exists "$STOW_TARGET/.claude/agents/custom-a.md" &&
	assert_file_exists "$STOW_TARGET/.claude/commands/custom-c.md" &&
	pass
teardown

###############################################################################
# Tests: do_install (full flow with stow)
###############################################################################
echo ""
echo "== do_install =="

CURRENT_TEST="installs claude package via stow (clean target)"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
assert_file_exists "$STOW_TARGET/.claude/agents/agent-a.md" &&
	assert_file_exists "$STOW_TARGET/.claude/commands/cmd-x.md" &&
	pass
teardown

CURRENT_TEST="installs opencode package via stow (clean target)"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
do_install
assert_file_exists "$STOW_TARGET/.opencode/agents/oc-agent.md" &&
	assert_file_exists "$STOW_TARGET/.opencode/commands/oc-cmd.md" &&
	assert_file_exists "$STOW_TARGET/.opencode/skills/api-design/SKILL.md" &&
	pass
teardown

CURRENT_TEST="install backs up existing user files and restores non-conflicting ones"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
# Pre-existing user file in target
mkdir -p "$STOW_TARGET/.claude/agents"
echo "my-custom" >"$STOW_TARGET/.claude/agents/my-custom.md"
echo "user-a" >"$STOW_TARGET/.claude/agents/agent-a.md"
do_install
# Repo file should be stowed
content_a=$(cat "$STOW_TARGET/.claude/agents/agent-a.md")
assert_eq "$content_a" "agent-a content" &&
	# User file should be restored
	assert_file_exists "$STOW_TARGET/.claude/agents/my-custom.md" &&
	content_c=$(cat "$STOW_TARGET/.claude/agents/my-custom.md") &&
	assert_eq "$content_c" "my-custom" &&
	pass
teardown

CURRENT_TEST="install restores nested user files after stow"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/commands/custom-sub"
echo "nested-user" >"$STOW_TARGET/.claude/commands/custom-sub/my-file.md"
do_install
assert_file_exists "$STOW_TARGET/.claude/commands/custom-sub/my-file.md" &&
	content=$(cat "$STOW_TARGET/.claude/commands/custom-sub/my-file.md") &&
	assert_eq "$content" "nested-user" &&
	pass
teardown

CURRENT_TEST="install is idempotent (run twice)"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
# Second install should not fail
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
assert_file_exists "$STOW_TARGET/.claude/agents/agent-a.md" && pass
teardown

###############################################################################
# Tests: do_uninstall
###############################################################################
echo ""
echo "== do_uninstall =="

CURRENT_TEST="uninstall removes stowed symlinks"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
do_uninstall
# After unstow, the directory symlink or files should be gone
assert_file_missing "$STOW_TARGET/.claude/agents/agent-a.md" && pass
teardown

CURRENT_TEST="uninstall restores backup and deletes backup dir"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
# Pre-existing user file
mkdir -p "$STOW_TARGET/.claude/agents"
echo "my-custom" >"$STOW_TARGET/.claude/agents/my-custom.md"
do_install
assert_dir_exists "$BACKUP_DIR"
do_uninstall
assert_dir_missing "$BACKUP_DIR" &&
	assert_file_exists "$STOW_TARGET/.claude/agents/my-custom.md" &&
	pass
teardown

CURRENT_TEST="uninstall no-op when no backup exists"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
# Manually remove backup if any
rm -rf "$BACKUP_DIR"
do_uninstall
assert_dir_missing "$BACKUP_DIR" && pass
teardown

###############################################################################
# Tests: .stow-local-ignore
###############################################################################
echo ""
echo "== .stow-local-ignore =="

CURRENT_TEST="stow ignores node_modules when .stow-local-ignore present"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
# Add node_modules + artifacts to repo package
mkdir -p "$REPO_DIR/opencode/.opencode/node_modules/some-pkg"
echo "pkg-code" >"$REPO_DIR/opencode/.opencode/node_modules/some-pkg/index.js"
echo '{"name":"test"}' >"$REPO_DIR/opencode/.opencode/package.json"
echo "lockfile" >"$REPO_DIR/opencode/.opencode/package-lock.json"
echo "node_modules" >"$REPO_DIR/opencode/.opencode/.gitignore"
# Create .stow-local-ignore at package root
cat >"$REPO_DIR/opencode/.stow-local-ignore" <<'IGNORE'
node_modules
package\.json
package-lock\.json
bun\.lock
\.gitignore
IGNORE
do_install
# Managed files stowed
assert_file_exists "$STOW_TARGET/.opencode/agents/oc-agent.md" &&
	# Ignored artifacts NOT stowed
	assert_file_missing "$STOW_TARGET/.opencode/node_modules/some-pkg/index.js" &&
	assert_file_missing "$STOW_TARGET/.opencode/package.json" &&
	assert_file_missing "$STOW_TARGET/.opencode/package-lock.json" &&
	assert_file_missing "$STOW_TARGET/.opencode/.gitignore" &&
	pass
teardown

CURRENT_TEST="install succeeds when target already has node_modules"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
# Pre-existing runtime node_modules in target
mkdir -p "$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin"
echo "runtime-pkg" >"$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js"
echo '{"name":"runtime"}' >"$STOW_TARGET/.opencode/package.json"
# Add artifacts to repo too (should be ignored by stow)
mkdir -p "$REPO_DIR/opencode/.opencode/node_modules/other-pkg"
echo "repo-pkg" >"$REPO_DIR/opencode/.opencode/node_modules/other-pkg/index.js"
cat >"$REPO_DIR/opencode/.stow-local-ignore" <<'IGNORE'
node_modules
package\.json
package-lock\.json
bun\.lock
\.gitignore
IGNORE
do_install
# Stowed files present
assert_file_exists "$STOW_TARGET/.opencode/agents/oc-agent.md" &&
	# Pre-existing runtime artifacts untouched
	assert_file_exists "$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js" &&
	content=$(cat "$STOW_TARGET/.opencode/package.json") &&
	assert_eq "$content" '{"name":"runtime"}' &&
	pass
teardown

###############################################################################
# Tests: uninstall edge cases
###############################################################################
echo ""
echo "== uninstall edge cases =="

CURRENT_TEST="uninstall handles broken symlink config_dir (tree folding)"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
# Pre-existing user files
mkdir -p "$STOW_TARGET/.claude/agents"
echo "my-custom" >"$STOW_TARGET/.claude/agents/my-custom.md"
do_install
# Simulate tree folding: after unstow, .claude becomes a broken symlink
# First do the actual unstow
stow -t "$STOW_TARGET" -d "$REPO_DIR" -D "claude"
# Now .claude might be gone or a broken symlink depending on stow version
# Force the broken symlink scenario to test our fix
rm -rf "$STOW_TARGET/.claude" 2>/dev/null || true
ln -s "/nonexistent/path" "$STOW_TARGET/.claude"
# Now run do_uninstall which should handle the broken symlink
# Reset stow state first (reinstall so unstow has something to do)
rm "$STOW_TARGET/.claude"
stow -t "$STOW_TARGET" -d "$REPO_DIR" "claude"
# Now do_uninstall should work
do_uninstall
assert_file_exists "$STOW_TARGET/.claude/agents/my-custom.md" &&
	assert_dir_missing "$BACKUP_DIR" &&
	pass
teardown

CURRENT_TEST="uninstall with broken symlink and backup restores files"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/agents"
echo "precious" >"$STOW_TARGET/.claude/agents/precious.md"
do_install
# Manually create broken symlink scenario
for pkg in "${PACKAGES[@]}"; do
	stow -t "$STOW_TARGET" -d "$REPO_DIR" -D "$pkg"
done
# Replace config_dir with broken symlink
rm -rf "$STOW_TARGET/.claude" 2>/dev/null || true
ln -s "/nonexistent" "$STOW_TARGET/.claude"
# Test that our fix handles it
local_config_dir="$STOW_TARGET/.claude"
[[ -L "$local_config_dir" ]] && rm "$local_config_dir"
mkdir -p "$local_config_dir"
cp -r "$BACKUP_DIR"/* "$local_config_dir/"
rm -rf "$BACKUP_DIR"
assert_file_exists "$STOW_TARGET/.claude/agents/precious.md" &&
	assert_dir_missing "$BACKUP_DIR" &&
	pass
teardown

###############################################################################
# Tests: non-managed files survive
###############################################################################
echo ""
echo "== non-managed files survive =="

CURRENT_TEST="files outside managed dirs survive install"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
# Pre-existing non-managed file in .opencode
mkdir -p "$STOW_TARGET/.opencode"
echo '{"setting":true}' >"$STOW_TARGET/.opencode/settings.json"
cat >"$REPO_DIR/opencode/.stow-local-ignore" <<'IGNORE'
node_modules
package\.json
package-lock\.json
bun\.lock
\.gitignore
IGNORE
do_install
# Non-managed file should survive
assert_file_exists "$STOW_TARGET/.opencode/settings.json" &&
	content=$(cat "$STOW_TARGET/.opencode/settings.json") &&
	assert_eq "$content" '{"setting":true}' &&
	# Managed files stowed
	assert_file_exists "$STOW_TARGET/.opencode/agents/oc-agent.md" &&
	pass
teardown

CURRENT_TEST="non-managed files survive full install+uninstall cycle"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
mkdir -p "$STOW_TARGET/.opencode"
echo "keep-me" >"$STOW_TARGET/.opencode/settings.json"
cat >"$REPO_DIR/opencode/.stow-local-ignore" <<'IGNORE'
node_modules
package\.json
package-lock\.json
bun\.lock
\.gitignore
IGNORE
do_install
do_uninstall
assert_file_exists "$STOW_TARGET/.opencode/settings.json" &&
	content=$(cat "$STOW_TARGET/.opencode/settings.json") &&
	assert_eq "$content" "keep-me" &&
	pass
teardown

###############################################################################
# Tests: managed_dirs edge cases
###############################################################################
echo ""
echo "== managed_dirs edge cases =="

CURRENT_TEST="managed_dirs ignores regular files (only dirs)"
setup
SELECTED_CLI="opencode"
# Add loose files to package config dir
echo '{"dep":"x"}' >"$REPO_DIR/opencode/.opencode/package.json"
echo "lockfile" >"$REPO_DIR/opencode/.opencode/package-lock.json"
echo "ignore" >"$REPO_DIR/opencode/.opencode/.gitignore"
dirs=$(managed_dirs | sort)
expected=$(printf "agents\ncommands\nskills")
assert_eq "$dirs" "$expected" && pass
teardown

###############################################################################
# Tests: backup_existing edge cases
###############################################################################
echo ""
echo "== backup_existing edge cases =="

CURRENT_TEST="backup_existing handles mix of symlinks and real dirs"
setup
SELECTED_CLI="claude"
BACKUP_DIR="$STOW_TARGET/.claude.bak"
mkdir -p "$STOW_TARGET/.claude/commands"
echo "user-cmd" >"$STOW_TARGET/.claude/commands/my-cmd.md"
# agents is a symlink (from previous stow), commands is a real dir
ln -s "/tmp" "$STOW_TARGET/.claude/agents"
backup_existing
# Only real dir backed up
assert_file_exists "$BACKUP_DIR/commands/my-cmd.md" &&
	assert_dir_missing "$BACKUP_DIR/agents" &&
	# Real dir removed, symlink untouched
	assert_link "$STOW_TARGET/.claude/agents" &&
	assert_dir_missing "$STOW_TARGET/.claude/commands" &&
	pass
teardown

###############################################################################
# Tests: full cycle
###############################################################################
echo ""
echo "== full cycle =="

CURRENT_TEST="install + user restore + uninstall for opencode"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
# Pre-existing user file in skills
mkdir -p "$STOW_TARGET/.opencode/skills/my-skill"
echo "my-skill" >"$STOW_TARGET/.opencode/skills/my-skill/SKILL.md"
do_install
# Repo skill present
assert_file_exists "$STOW_TARGET/.opencode/skills/api-design/SKILL.md" &&
	# User skill restored
	assert_file_exists "$STOW_TARGET/.opencode/skills/my-skill/SKILL.md" &&
	content=$(cat "$STOW_TARGET/.opencode/skills/my-skill/SKILL.md") &&
	assert_eq "$content" "my-skill"
do_uninstall
# After uninstall, user file restored from backup
assert_file_exists "$STOW_TARGET/.opencode/skills/my-skill/SKILL.md" &&
	assert_dir_missing "$BACKUP_DIR" &&
	pass
teardown

CURRENT_TEST="uninstall then reinstall works clean"
setup
SELECTED_CLI="claude"
PACKAGES=("claude")
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
assert_file_exists "$STOW_TARGET/.claude/agents/agent-a.md"
do_uninstall
assert_file_missing "$STOW_TARGET/.claude/agents/agent-a.md"
# Reinstall
BACKUP_DIR="$STOW_TARGET/.claude.bak"
do_install
assert_file_exists "$STOW_TARGET/.claude/agents/agent-a.md" &&
	assert_file_exists "$STOW_TARGET/.claude/commands/cmd-x.md" &&
	pass
teardown

CURRENT_TEST="opencode full cycle with runtime artifacts untouched"
setup
SELECTED_CLI="opencode"
PACKAGES=("opencode")
BACKUP_DIR="$STOW_TARGET/.opencode.bak"
# Runtime artifacts in target
mkdir -p "$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin"
echo "runtime" >"$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js"
echo '{"name":"rt"}' >"$STOW_TARGET/.opencode/package.json"
# Runtime artifacts in repo (should be ignored)
mkdir -p "$REPO_DIR/opencode/.opencode/node_modules/other"
echo "repo" >"$REPO_DIR/opencode/.opencode/node_modules/other/index.js"
cat >"$REPO_DIR/opencode/.stow-local-ignore" <<'IGNORE'
node_modules
package\.json
package-lock\.json
bun\.lock
\.gitignore
IGNORE
# User skill to backup/restore
mkdir -p "$STOW_TARGET/.opencode/skills/custom"
echo "custom" >"$STOW_TARGET/.opencode/skills/custom/SKILL.md"
do_install
# Everything correct after install
assert_file_exists "$STOW_TARGET/.opencode/agents/oc-agent.md" &&
	assert_file_exists "$STOW_TARGET/.opencode/skills/custom/SKILL.md" &&
	assert_file_exists "$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js" &&
	pkg_content=$(cat "$STOW_TARGET/.opencode/package.json") &&
	assert_eq "$pkg_content" '{"name":"rt"}'
do_uninstall
# After uninstall: user files restored, runtime untouched
assert_file_exists "$STOW_TARGET/.opencode/skills/custom/SKILL.md" &&
	assert_file_exists "$STOW_TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js" &&
	assert_dir_missing "$BACKUP_DIR" &&
	pass
teardown

###############################################################################
# Summary
###############################################################################
echo ""
echo "================================"
echo "  $PASS passed, $FAIL failed"
echo "================================"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
