#!/usr/bin/env bash
# Unit tests for ./run — symlink-based installer.
# Sources run directly (no function duplication). Runs under set -eo pipefail.
#
# Usage:  bash test_run.sh

set -eo pipefail

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

assert_link() { [[ -L "$1" ]] || {
	fail "expected symlink $1"
	return 1
}; }
assert_link_target() { [[ "$(readlink "$1")" == "$2" ]] || {
	fail "symlink $1 -> $(readlink "$1"), expected $2"
	return 1
}; }
assert_file_exists() { [[ -e "$1" ]] || {
	fail "expected $1 to exist"
	return 1
}; }
assert_not_exists() { [[ ! -e "$1" && ! -L "$1" ]] || {
	fail "expected $1 absent"
	return 1
}; }
assert_not_link() { [[ ! -L "$1" ]] || {
	fail "expected $1 not a symlink"
	return 1
}; }
assert_eq() { [[ "$1" == "$2" ]] || {
	fail "expected '$2', got '$1'"
	return 1
}; }
assert_contains() { [[ "$1" == *"$2"* ]] || {
	fail "expected to contain '$2'"
	return 1
}; }

# ---------------------------------------------------------------------------
# Source run (functions only, main won't execute thanks to BASH_SOURCE guard)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/run"

# Override confirm_fn default — tests set their own per-test
confirm_fn() { return 1; }

# ---------------------------------------------------------------------------
# Setup / teardown
# ---------------------------------------------------------------------------
TMP=""

setup() {
	TMP=$(mktemp -d)
	REPO_DIR="$TMP/repo"
	TARGET="$TMP/home"
	mkdir -p "$TARGET"

	# Claude package
	mkdir -p "$REPO_DIR/claude/.claude/agents"
	mkdir -p "$REPO_DIR/claude/.claude/commands"
	echo "agent-a" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
	echo "agent-b" >"$REPO_DIR/claude/.claude/agents/agent-b.md"
	echo "cmd-x" >"$REPO_DIR/claude/.claude/commands/cmd-x.md"
	echo "cmd-y" >"$REPO_DIR/claude/.claude/commands/cmd-y.md"

	# OpenCode package
	mkdir -p "$REPO_DIR/opencode/.opencode/agents"
	mkdir -p "$REPO_DIR/opencode/.opencode/commands"
	mkdir -p "$REPO_DIR/opencode/.opencode/skills/api-design"
	mkdir -p "$REPO_DIR/opencode/.opencode/skills/caveman"
	echo "oc-agent" >"$REPO_DIR/opencode/.opencode/agents/oc-agent.md"
	echo "oc-cmd" >"$REPO_DIR/opencode/.opencode/commands/oc-cmd.md"
	echo "skill-ad" >"$REPO_DIR/opencode/.opencode/skills/api-design/SKILL.md"
	echo "skill-cv" >"$REPO_DIR/opencode/.opencode/skills/caveman/SKILL.md"

	# Reset confirm_fn to default (refuse)
	confirm_fn() { return 1; }
}

teardown() { [[ -n "$TMP" ]] && rm -rf "$TMP"; }

###############################################################################
echo ""
echo "== list_all =="

CURRENT_TEST="lists claude agents and commands"
setup
CLI="claude"
items=$(list_all)
assert_contains "$items" "agents/agent-a" &&
	assert_contains "$items" "agents/agent-b" &&
	assert_contains "$items" "commands/cmd-x" &&
	assert_contains "$items" "commands/cmd-y" &&
	pass
teardown

CURRENT_TEST="lists opencode agents, commands, and skills"
setup
CLI="opencode"
items=$(list_all)
assert_contains "$items" "agents/oc-agent" &&
	assert_contains "$items" "commands/oc-cmd" &&
	assert_contains "$items" "skills/api-design" &&
	assert_contains "$items" "skills/caveman" &&
	pass
teardown

CURRENT_TEST="excludes node_modules"
setup
CLI="opencode"
mkdir -p "$REPO_DIR/opencode/.opencode/node_modules/some-pkg"
echo "x" >"$REPO_DIR/opencode/.opencode/node_modules/some-pkg/index.js"
items=$(list_all)
assert_eq "$(echo "$items" | grep -c node_modules)" "0" && pass
teardown

###############################################################################
echo ""
echo "== src_of / dest_of =="

CURRENT_TEST="paths for agent"
setup
CLI="claude"
assert_eq "$(src_of agents/agent-a)" "$REPO_DIR/claude/.claude/agents/agent-a.md" &&
	assert_eq "$(dest_of agents/agent-a)" "$TARGET/.claude/agents/agent-a.md" &&
	pass
teardown

CURRENT_TEST="paths for skill (dir, no .md)"
setup
CLI="opencode"
assert_eq "$(src_of skills/api-design)" "$REPO_DIR/opencode/.opencode/skills/api-design" &&
	assert_eq "$(dest_of skills/api-design)" "$TARGET/.opencode/skills/api-design" &&
	pass
teardown

###############################################################################
echo ""
echo "== link_item =="

CURRENT_TEST="creates symlink to repo"
setup
CLI="claude"
link_item "agents/agent-a"
dest=$(dest_of "agents/agent-a")
assert_link "$dest" &&
	assert_link_target "$dest" "$REPO_DIR/claude/.claude/agents/agent-a.md" &&
	pass
teardown

CURRENT_TEST="creates parent dirs"
setup
CLI="opencode"
link_item "skills/api-design"
dest=$(dest_of "skills/api-design")
assert_link "$dest" && pass
teardown

CURRENT_TEST="idempotent — second call is no-op"
setup
CLI="claude"
link_item "agents/agent-a"
link_item "agents/agent-a"
dest=$(dest_of "agents/agent-a")
assert_link "$dest" && pass
teardown

CURRENT_TEST="auto-migrates identical non-symlink file"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
cp "$REPO_DIR/claude/.claude/agents/agent-a.md" "$TARGET/.claude/agents/agent-a.md"
link_item "agents/agent-a"
assert_link "$TARGET/.claude/agents/agent-a.md" &&
	assert_link_target "$TARGET/.claude/agents/agent-a.md" "$(src_of agents/agent-a)" &&
	pass
teardown

CURRENT_TEST="auto-migrates different file on confirm yes"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "modified" >"$TARGET/.claude/agents/agent-a.md"
confirm_fn() { return 0; }
link_item "agents/agent-a"
assert_link "$TARGET/.claude/agents/agent-a.md" &&
	assert_link_target "$TARGET/.claude/agents/agent-a.md" "$(src_of agents/agent-a)" &&
	pass
teardown

CURRENT_TEST="returns 1 on different file + confirm no"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "modified" >"$TARGET/.claude/agents/agent-a.md"
confirm_fn() { return 1; }
rc=0
link_item "agents/agent-a" || rc=$?
assert_eq "$rc" "1" &&
	assert_not_link "$TARGET/.claude/agents/agent-a.md" &&
	pass
teardown

CURRENT_TEST="auto-migrates foreign symlink with identical target"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
other="$TMP/other-agent-a.md"
cp "$REPO_DIR/claude/.claude/agents/agent-a.md" "$other"
ln -s "$other" "$TARGET/.claude/agents/agent-a.md"
link_item "agents/agent-a"
assert_link_target "$TARGET/.claude/agents/agent-a.md" "$(src_of agents/agent-a)" && pass
teardown

###############################################################################
echo ""
echo "== unlink_item =="

CURRENT_TEST="removes our symlink"
setup
CLI="claude"
link_item "agents/agent-a"
unlink_item "agents/agent-a"
assert_not_exists "$(dest_of agents/agent-a)" && pass
teardown

CURRENT_TEST="leaves non-symlink files alone"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "user-file" >"$TARGET/.claude/agents/agent-a.md"
unlink_item "agents/agent-a"
assert_file_exists "$TARGET/.claude/agents/agent-a.md" &&
	assert_not_link "$TARGET/.claude/agents/agent-a.md" &&
	pass
teardown

CURRENT_TEST="leaves foreign symlinks alone"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
ln -s "/other/repo/agent-a.md" "$TARGET/.claude/agents/agent-a.md"
unlink_item "agents/agent-a"
assert_link "$TARGET/.claude/agents/agent-a.md" &&
	assert_link_target "$TARGET/.claude/agents/agent-a.md" "/other/repo/agent-a.md" &&
	pass
teardown

###############################################################################
echo ""
echo "== is_ours =="

CURRENT_TEST="true for our symlink"
setup
CLI="claude"
link_item "agents/agent-a"
is_ours "$(dest_of agents/agent-a)" && pass
teardown

CURRENT_TEST="false for foreign symlink"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
ln -s "/other/path" "$TARGET/.claude/agents/agent-a.md"
! is_ours "$TARGET/.claude/agents/agent-a.md" && pass
teardown

CURRENT_TEST="false for regular file"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "x" >"$TARGET/.claude/agents/agent-a.md"
! is_ours "$TARGET/.claude/agents/agent-a.md" && pass
teardown

CURRENT_TEST="false for nonexistent"
setup
CLI="claude"
! is_ours "$TARGET/.claude/agents/nope.md" && pass
teardown

###############################################################################
echo ""
echo "== full cycle =="

CURRENT_TEST="install all claude items"
setup
CLI="claude"
while read -r item; do link_item "$item"; done <<<"$(list_all)"
assert_link "$(dest_of agents/agent-a)" &&
	assert_link "$(dest_of agents/agent-b)" &&
	assert_link "$(dest_of commands/cmd-x)" &&
	assert_link "$(dest_of commands/cmd-y)" &&
	pass
teardown

CURRENT_TEST="install all opencode items including skills"
setup
CLI="opencode"
while read -r item; do link_item "$item"; done <<<"$(list_all)"
assert_link "$(dest_of agents/oc-agent)" &&
	assert_link "$(dest_of skills/api-design)" &&
	assert_link "$(dest_of skills/caveman)" &&
	pass
teardown

CURRENT_TEST="uninstall all — clean removal"
setup
CLI="claude"
while read -r item; do link_item "$item"; done <<<"$(list_all)"
while read -r item; do unlink_item "$item"; done <<<"$(list_all)"
assert_not_exists "$(dest_of agents/agent-a)" &&
	assert_not_exists "$(dest_of commands/cmd-x)" &&
	pass
teardown

CURRENT_TEST="install + uninstall leaves user files untouched"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "my-custom" >"$TARGET/.claude/agents/my-custom.md"
confirm_fn() { return 0; }
while read -r item; do link_item "$item"; done <<<"$(list_all)"
while read -r item; do unlink_item "$item"; done <<<"$(list_all)"
assert_file_exists "$TARGET/.claude/agents/my-custom.md" &&
	content=$(cat "$TARGET/.claude/agents/my-custom.md") &&
	assert_eq "$content" "my-custom" &&
	pass
teardown

CURRENT_TEST="runtime artifacts never touched"
setup
CLI="opencode"
mkdir -p "$TARGET/.opencode/node_modules/@opencode-ai/plugin"
echo "runtime" >"$TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js"
echo '{"name":"rt"}' >"$TARGET/.opencode/package.json"
while read -r item; do link_item "$item"; done <<<"$(list_all)"
assert_file_exists "$TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js" &&
	assert_file_exists "$TARGET/.opencode/package.json" &&
	assert_link "$(dest_of skills/api-design)" &&
	pass
teardown

CURRENT_TEST="selective install — only some items"
setup
CLI="claude"
link_item "agents/agent-a"
link_item "commands/cmd-x"
assert_link "$(dest_of agents/agent-a)" &&
	assert_not_exists "$(dest_of agents/agent-b)" &&
	assert_link "$(dest_of commands/cmd-x)" &&
	assert_not_exists "$(dest_of commands/cmd-y)" &&
	pass
teardown

CURRENT_TEST="selective uninstall — only some items"
setup
CLI="claude"
while read -r item; do link_item "$item"; done <<<"$(list_all)"
unlink_item "agents/agent-a"
assert_not_exists "$(dest_of agents/agent-a)" &&
	assert_link "$(dest_of agents/agent-b)" &&
	assert_link "$(dest_of commands/cmd-x)" &&
	pass
teardown

CURRENT_TEST="reinstall after uninstall"
setup
CLI="claude"
link_item "agents/agent-a"
unlink_item "agents/agent-a"
assert_not_exists "$(dest_of agents/agent-a)"
link_item "agents/agent-a"
assert_link "$(dest_of agents/agent-a)" && pass
teardown

###############################################################################
echo ""
echo "== do_install_all =="

CURRENT_TEST="install_all links every claude item"
setup
CLI="claude"
do_install_all >/dev/null
assert_link "$(dest_of agents/agent-a)" &&
	assert_link "$(dest_of agents/agent-b)" &&
	assert_link "$(dest_of commands/cmd-x)" &&
	assert_link "$(dest_of commands/cmd-y)" &&
	pass
teardown

CURRENT_TEST="install_all links every opencode item including skills"
setup
CLI="opencode"
do_install_all >/dev/null
assert_link "$(dest_of agents/oc-agent)" &&
	assert_link "$(dest_of commands/oc-cmd)" &&
	assert_link "$(dest_of skills/api-design)" &&
	assert_link "$(dest_of skills/caveman)" &&
	pass
teardown

CURRENT_TEST="install_all idempotent — second call is no-op"
setup
CLI="claude"
do_install_all >/dev/null
do_install_all >/dev/null
assert_link "$(dest_of agents/agent-a)" &&
	assert_link "$(dest_of commands/cmd-x)" &&
	pass
teardown

CURRENT_TEST="install_all auto-migrates identical user files"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
cp "$REPO_DIR/claude/.claude/agents/agent-a.md" "$TARGET/.claude/agents/agent-a.md"
do_install_all >/dev/null
assert_link "$TARGET/.claude/agents/agent-a.md" &&
	assert_link_target "$TARGET/.claude/agents/agent-a.md" "$(src_of agents/agent-a)" &&
	assert_link "$(dest_of agents/agent-b)" &&
	pass
teardown

CURRENT_TEST="install_all preserves runtime artifacts"
setup
CLI="opencode"
mkdir -p "$TARGET/.opencode/node_modules/@opencode-ai/plugin"
echo "runtime" >"$TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js"
echo '{"name":"rt"}' >"$TARGET/.opencode/package.json"
do_install_all >/dev/null
assert_file_exists "$TARGET/.opencode/node_modules/@opencode-ai/plugin/index.js" &&
	assert_file_exists "$TARGET/.opencode/package.json" &&
	assert_link "$(dest_of skills/api-design)" &&
	pass
teardown

CURRENT_TEST="install_all aborts on migrate conflict refused"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "modified" >"$TARGET/.claude/agents/agent-a.md"
confirm_fn() { return 1; }
rc=0
do_install_all 2>/dev/null || rc=$?
assert_eq "$rc" "1" &&
	assert_not_link "$TARGET/.claude/agents/agent-a.md" &&
	pass
teardown

CURRENT_TEST="install_all migrates conflict on confirm yes"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "modified" >"$TARGET/.claude/agents/agent-a.md"
confirm_fn() { return 0; }
do_install_all >/dev/null
assert_link "$TARGET/.claude/agents/agent-a.md" &&
	assert_link "$(dest_of agents/agent-b)" &&
	pass
teardown

###############################################################################
echo ""
echo "== desc_of / list_display / strip_desc =="

CURRENT_TEST="desc_of extracts description from agent frontmatter"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: First test agent. More details here.
---
content
EOF
desc=$(desc_of "agents/agent-a")
assert_eq "$desc" "First test agent" && pass
teardown

CURRENT_TEST="desc_of extracts description from skill SKILL.md"
setup
CLI="opencode"
cat >"$REPO_DIR/opencode/.opencode/skills/api-design/SKILL.md" <<'EOF'
---
name: api-design
description: REST API design patterns. Including pagination and more.
---
content
EOF
desc=$(desc_of "skills/api-design")
assert_eq "$desc" "REST API design patterns" && pass
teardown

CURRENT_TEST="desc_of returns empty for file without description"
setup
CLI="claude"
echo "just content" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
desc=$(desc_of "agents/agent-a")
assert_eq "$desc" "" && pass
teardown

CURRENT_TEST="list_display appends description"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Agent alpha. Extra info.
---
EOF
cat >"$REPO_DIR/claude/.claude/agents/agent-b.md" <<'EOF'
---
description: Agent beta. Extra info.
---
EOF
items=$(list_all)
display=$(list_display "$items")
assert_contains "$display" "agents/agent-a — Agent alpha" &&
	assert_contains "$display" "agents/agent-b — Agent beta" &&
	pass
teardown

CURRENT_TEST="list_display omits separator when no description"
setup
CLI="claude"
echo "no frontmatter" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
items="agents/agent-a"
display=$(list_display "$items")
assert_eq "$display" "agents/agent-a" && pass
teardown

CURRENT_TEST="strip_desc removes description suffix"
setup
result=$(echo "agents/agent-a — Some description" | strip_desc)
assert_eq "$result" "agents/agent-a" && pass
teardown

CURRENT_TEST="strip_desc is no-op when no description"
setup
result=$(echo "agents/agent-a" | strip_desc)
assert_eq "$result" "agents/agent-a" && pass
teardown

CURRENT_TEST="desc_of truncates long descriptions to 120 chars"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: This is a very long description that should definitely be truncated because it goes on and on and on and on and on and on and on and on and keeps going
---
EOF
desc=$(desc_of "agents/agent-a")
[[ ${#desc} -le 120 ]] && assert_contains "$desc" "..." && pass
teardown

CURRENT_TEST="desc_of uses full text when no period and under 120 chars"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Expert code reviewer for multiple languages
---
EOF
desc=$(desc_of "agents/agent-a")
assert_eq "$desc" "Expert code reviewer for multiple languages" && pass
teardown

CURRENT_TEST="desc_of handles YAML quoted description"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: "A comprehensive verification system. With extras."
---
EOF
desc=$(desc_of "agents/agent-a")
assert_eq "$desc" "A comprehensive verification system" && pass
teardown

CURRENT_TEST="list_display mixed — some items with desc, some without"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Has a description. And more.
---
EOF
echo "no frontmatter" >"$REPO_DIR/claude/.claude/agents/agent-b.md"
items=$(list_all)
display=$(list_display "$items")
assert_contains "$display" "agents/agent-a — Has a description" &&
	assert_contains "$display" "agents/agent-b" &&
	line_b=$(echo "$display" | grep "^agents/agent-b") &&
	[[ "$line_b" != *" — "* ]] &&
	pass
teardown

CURRENT_TEST="strip_desc handles em dash inside description"
setup
result=$(echo "agents/code-reviewer — Expert reviewer — quality, security" | strip_desc)
assert_eq "$result" "agents/code-reviewer" && pass
teardown

CURRENT_TEST="list_all skips empty category directories"
setup
CLI="claude"
mkdir -p "$REPO_DIR/claude/.claude/empty-cat"
items=$(list_all)
[[ "$items" != *"empty-cat"* ]] && pass || fail "empty category should not appear"
teardown

###############################################################################
echo ""
echo "== unfold_dir (stow directory symlinks) =="

CURRENT_TEST="link_item unfolds stow directory symlink"
setup
CLI="claude"
# Simulate stow: TARGET/agents/ is a dir-symlink into repo
rm -rf "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude"
ln -s "$REPO_DIR/claude/.claude/agents" "$TARGET/.claude/agents"
# Verify it's a dir symlink
[[ -L "$TARGET/.claude/agents" ]] || fail "precondition: should be symlink"
# Now link an item — should unfold the dir first
link_item "agents/agent-a"
# Dir should be a real dir now, not a symlink
[[ ! -L "$TARGET/.claude/agents" ]] || { fail "dir should no longer be symlink"; }
[[ -d "$TARGET/.claude/agents" ]] || { fail "dir should exist as real dir"; }
# The linked item should be a file symlink into repo
assert_link "$TARGET/.claude/agents/agent-a.md" &&
	assert_link_target "$TARGET/.claude/agents/agent-a.md" "$REPO_DIR/claude/.claude/agents/agent-a.md" &&
	pass
teardown

CURRENT_TEST="unfold preserves other files in stow dir"
setup
CLI="claude"
rm -rf "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude"
ln -s "$REPO_DIR/claude/.claude/agents" "$TARGET/.claude/agents"
# Link one item to trigger unfold
link_item "agents/agent-a"
# agent-b should have been copied from repo during unfold
assert_file_exists "$TARGET/.claude/agents/agent-b.md" &&
	[[ ! -L "$TARGET/.claude/agents/agent-b.md" ]] &&
	pass
teardown

CURRENT_TEST="unfold does not corrupt repo files"
setup
CLI="claude"
rm -rf "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude"
ln -s "$REPO_DIR/claude/.claude/agents" "$TARGET/.claude/agents"
link_item "agents/agent-a"
# Repo source must still be a regular file, not a symlink
[[ -f "$REPO_DIR/claude/.claude/agents/agent-a.md" && ! -L "$REPO_DIR/claude/.claude/agents/agent-a.md" ]] &&
	pass || fail "repo file corrupted"
teardown

CURRENT_TEST="unfold skips non-repo dir symlinks"
setup
CLI="claude"
# Dir symlink pointing somewhere else (not our repo)
rm -rf "$TARGET/.claude/agents"
mkdir -p "$TARGET/.claude" "$TMP/other-agents"
echo "other" >"$TMP/other-agents/agent-a.md"
ln -s "$TMP/other-agents" "$TARGET/.claude/agents"
# Just test unfold_dir, not full link_item
unfold_dir "$TARGET/.claude/agents/agent-a.md"
# Should NOT unfold — dir is still a symlink (not ours)
[[ -L "$TARGET/.claude/agents" ]] && pass || fail "should not unfold foreign dir symlink"
teardown

###############################################################################
echo ""
echo "== install via display (end-to-end) =="

CURRENT_TEST="strip_desc from display line → link_item works"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Test agent for e2e. Details.
---
content
EOF
items=$(list_all)
display=$(list_display "$items")
line=$(echo "$display" | grep "^agents/agent-a")
item=$(echo "$line" | strip_desc)
link_item "$item"
assert_link "$(dest_of agents/agent-a)" &&
	assert_link_target "$(dest_of agents/agent-a)" "$(src_of agents/agent-a)" &&
	pass
teardown

CURRENT_TEST="install_all then uninstall via display lines — clean roundtrip"
setup
CLI="opencode"
do_install_all >/dev/null
assert_link "$(dest_of agents/oc-agent)" &&
	assert_link "$(dest_of skills/api-design)" || { fail "install_all failed"; }
items=$(list_all)
while read -r item; do
	unlink_item "$item"
done <<<"$items"
assert_not_exists "$(dest_of agents/oc-agent)" &&
	assert_not_exists "$(dest_of commands/oc-cmd)" &&
	assert_not_exists "$(dest_of skills/api-design)" &&
	assert_not_exists "$(dest_of skills/caveman)" &&
	pass
teardown

###############################################################################
echo ""
echo "== deps_of =="

CURRENT_TEST="deps_of extracts claude agent dependencies"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Test agent.
---
## Bootstrap
- `~/.claude/commands/caveman.md`
- `~/.claude/commands/swift-concurrency-6-2.md`
- `~/.claude/commands/swiftui-patterns.md`
EOF
echo "x" >"$REPO_DIR/claude/.claude/commands/caveman.md"
echo "x" >"$REPO_DIR/claude/.claude/commands/swift-concurrency-6-2.md"
echo "x" >"$REPO_DIR/claude/.claude/commands/swiftui-patterns.md"
deps=$(deps_of "agents/agent-a")
assert_contains "$deps" "commands/caveman" &&
	assert_contains "$deps" "commands/swift-concurrency-6-2" &&
	assert_contains "$deps" "commands/swiftui-patterns" &&
	assert_eq "$(echo "$deps" | wc -l | tr -d ' ')" "3" &&
	pass
teardown

CURRENT_TEST="deps_of extracts opencode agent dependencies (skills)"
setup
CLI="opencode"
cat >"$REPO_DIR/opencode/.opencode/agents/oc-agent.md" <<'EOF'
---
description: Test OC agent.
---
## Bootstrap
- `~/.opencode/skills/caveman/SKILL.md`
- `~/.opencode/skills/api-design/SKILL.md`
EOF
deps=$(deps_of "agents/oc-agent")
assert_contains "$deps" "skills/caveman" &&
	assert_contains "$deps" "skills/api-design" &&
	assert_eq "$(echo "$deps" | wc -l | tr -d ' ')" "2" &&
	pass
teardown

CURRENT_TEST="deps_of returns nothing for non-agent items"
setup
CLI="claude"
deps=$(deps_of "commands/cmd-x")
assert_eq "$deps" "" && pass
teardown

CURRENT_TEST="deps_of returns nothing for agent without bootstrap"
setup
CLI="claude"
echo "---
description: No deps.
---
Just content" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
deps=$(deps_of "agents/agent-a")
assert_eq "$deps" "" && pass
teardown

CURRENT_TEST="list_display shows dep count for agents with deps"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Agent with deps. More info.
---
## Bootstrap
- `~/.claude/commands/cmd-x.md`
- `~/.claude/commands/cmd-y.md`
EOF
items="agents/agent-a"
display=$(list_display "$items")
assert_contains "$display" "[+2 deps]" && pass
teardown

CURRENT_TEST="list_display no dep count for agents without deps"
setup
CLI="claude"
echo "---
description: Agent solo. No deps.
---
content" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
items="agents/agent-a"
display=$(list_display "$items")
[[ "$display" != *"[+"* ]] && pass || fail "should not show dep count"
teardown

CURRENT_TEST="list_display no dep count for commands"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/commands/cmd-x.md" <<'EOF'
---
description: A command. Details.
---
EOF
items="commands/cmd-x"
display=$(list_display "$items")
[[ "$display" != *"[+"* ]] && pass || fail "commands should not show dep count"
teardown

###############################################################################
echo ""
echo "== list_visible =="

CURRENT_TEST="list_visible hides non-standalone agent deps"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Test agent.
---
## Bootstrap
- `~/.claude/commands/cmd-x.md`
- `~/.claude/commands/cmd-y.md`
EOF
visible=$(list_visible)
assert_contains "$visible" "agents/agent-a" &&
	assert_contains "$visible" "agents/agent-b" &&
	[[ "$visible" != *"commands/cmd-x"* ]] &&
	[[ "$visible" != *"commands/cmd-y"* ]] &&
	pass || fail "deps should be hidden"
teardown

CURRENT_TEST="list_visible keeps standalone deps visible"
setup
CLI="claude"
echo "x" >"$REPO_DIR/claude/.claude/commands/caveman.md"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Test agent.
---
## Bootstrap
- `~/.claude/commands/caveman.md`
- `~/.claude/commands/cmd-x.md`
EOF
visible=$(list_visible)
assert_contains "$visible" "commands/caveman" &&
	[[ "$visible" != *"commands/cmd-x"* ]] &&
	pass || fail "caveman should stay visible, cmd-x should be hidden"
teardown

CURRENT_TEST="list_visible keeps orphan commands visible"
setup
CLI="claude"
echo "no deps" >"$REPO_DIR/claude/.claude/agents/agent-a.md"
echo "no deps" >"$REPO_DIR/claude/.claude/agents/agent-b.md"
visible=$(list_visible)
assert_contains "$visible" "commands/cmd-x" &&
	assert_contains "$visible" "commands/cmd-y" &&
	pass
teardown

CURRENT_TEST="list_visible works for opencode with skills"
setup
CLI="opencode"
cat >"$REPO_DIR/opencode/.opencode/agents/oc-agent.md" <<'EOF'
---
description: Test OC agent.
---
## Bootstrap
- `~/.opencode/skills/api-design/SKILL.md`
EOF
visible=$(list_visible)
assert_contains "$visible" "agents/oc-agent" &&
	assert_contains "$visible" "commands/oc-cmd" &&
	assert_contains "$visible" "skills/caveman" &&
	[[ "$visible" != *"skills/api-design"* ]] &&
	pass || fail "api-design should be hidden (dep of oc-agent), caveman standalone"
teardown

CURRENT_TEST="list_visible hides opencode commands matching skill deps"
setup
CLI="opencode"
echo "x" >"$REPO_DIR/opencode/.opencode/commands/api-design.md"
cat >"$REPO_DIR/opencode/.opencode/agents/oc-agent.md" <<'EOF'
---
description: Test OC agent.
---
## Bootstrap
- `~/.opencode/skills/api-design/SKILL.md`
EOF
visible=$(list_visible)
[[ "$visible" != *"skills/api-design"* ]] || { fail "skills/api-design should be hidden"; }
[[ "$visible" != *"commands/api-design"* ]] && pass || fail "commands/api-design should be hidden too (matches skill dep)"
teardown

CURRENT_TEST="list_visible deduplicates opencode commands+skills standalones"
setup
CLI="opencode"
echo "x" >"$REPO_DIR/opencode/.opencode/commands/caveman.md"
echo "no deps" >"$REPO_DIR/opencode/.opencode/agents/oc-agent.md"
visible=$(list_visible)
caveman_count=$(echo "$visible" | grep -c "caveman")
assert_eq "$caveman_count" "1" && pass || fail "caveman should appear exactly once, got $caveman_count"
teardown

CURRENT_TEST="list_visible dedup does not affect claude"
setup
CLI="claude"
visible=$(list_visible)
assert_contains "$visible" "commands/cmd-x" &&
	assert_contains "$visible" "commands/cmd-y" &&
	pass
teardown

CURRENT_TEST="all_agent_deps collects deps from all agents"
setup
CLI="claude"
cat >"$REPO_DIR/claude/.claude/agents/agent-a.md" <<'EOF'
---
description: Agent A.
---
## Bootstrap
- `~/.claude/commands/cmd-x.md`
EOF
cat >"$REPO_DIR/claude/.claude/agents/agent-b.md" <<'EOF'
---
description: Agent B.
---
## Bootstrap
- `~/.claude/commands/cmd-y.md`
EOF
deps=$(all_agent_deps)
assert_contains "$deps" "commands/cmd-x" &&
	assert_contains "$deps" "commands/cmd-y" &&
	pass
teardown

CURRENT_TEST="is_standalone returns true for standalone items"
setup
is_standalone "commands/caveman" && is_standalone "commands/security-review" && pass
teardown

CURRENT_TEST="is_standalone returns false for non-standalone items"
setup
! is_standalone "commands/swift-concurrency-6-2" && ! is_standalone "skills/api-design" && pass
teardown

###############################################################################
echo ""
echo "== migrate_item =="

CURRENT_TEST="migrate_item replaces identical file with symlink"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
cp "$REPO_DIR/claude/.claude/agents/agent-a.md" "$TARGET/.claude/agents/agent-a.md"
rc=0
migrate_item "agents/agent-a" || rc=$?
assert_eq "$rc" "0" &&
	assert_link "$(dest_of agents/agent-a)" &&
	assert_link_target "$(dest_of agents/agent-a)" "$(src_of agents/agent-a)" &&
	pass
teardown

CURRENT_TEST="migrate_item returns 2 when no file at dest"
setup
CLI="claude"
rc=0
migrate_item "agents/agent-a" || rc=$?
assert_eq "$rc" "2" && pass
teardown

CURRENT_TEST="migrate_item returns 2 when already ours"
setup
CLI="claude"
link_item "agents/agent-a"
rc=0
migrate_item "agents/agent-a" || rc=$?
assert_eq "$rc" "2" && pass
teardown

CURRENT_TEST="migrate_item replaces identical skill dir"
setup
CLI="opencode"
mkdir -p "$TARGET/.opencode/skills/api-design"
cp "$REPO_DIR/opencode/.opencode/skills/api-design/SKILL.md" "$TARGET/.opencode/skills/api-design/SKILL.md"
rc=0
migrate_item "skills/api-design" || rc=$?
assert_eq "$rc" "0" &&
	assert_link "$(dest_of skills/api-design)" &&
	pass
teardown

CURRENT_TEST="migrate_item with conflict replaces on confirm yes"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "modified content" >"$TARGET/.claude/agents/agent-a.md"
confirm_fn() { return 0; }
rc=0
migrate_item "agents/agent-a" || rc=$?
assert_eq "$rc" "0" &&
	assert_link "$(dest_of agents/agent-a)" &&
	pass
teardown

CURRENT_TEST="migrate_item with conflict returns 1 on confirm no"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "modified content" >"$TARGET/.claude/agents/agent-a.md"
confirm_fn() { return 1; }
rc=0
migrate_item "agents/agent-a" || rc=$?
assert_eq "$rc" "1" &&
	assert_not_link "$TARGET/.claude/agents/agent-a.md" &&
	content=$(cat "$TARGET/.claude/agents/agent-a.md") &&
	assert_eq "$content" "modified content" &&
	pass
teardown

CURRENT_TEST="migrate_item replaces foreign symlink with identical target"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
other="$TMP/other-agent-a.md"
cp "$REPO_DIR/claude/.claude/agents/agent-a.md" "$other"
ln -s "$other" "$TARGET/.claude/agents/agent-a.md"
rc=0
migrate_item "agents/agent-a" || rc=$?
assert_eq "$rc" "0" &&
	assert_link_target "$(dest_of agents/agent-a)" "$(src_of agents/agent-a)" &&
	pass
teardown

###############################################################################
echo ""
echo "================================"
echo "  $PASS passed, $FAIL failed"
echo "================================"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
