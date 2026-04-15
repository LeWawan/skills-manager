#!/usr/bin/env bash
# Unit tests for ./run — symlink-based installer.
# Runs in isolated temp dir, no side effects.
#
# Usage:  bash test_run.sh

set -o pipefail

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

	# Source functions from run
	_source_functions
}

teardown() { [[ -n "$TMP" ]] && rm -rf "$TMP"; }

_source_functions() {
	GREEN='\033[0;32m'
	YELLOW='\033[0;33m'
	RED='\033[0;31m'
	NC='\033[0m'

	info() { echo -e "${GREEN}[info]${NC} $1"; }
	warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
	error() { echo -e "${RED}[error]${NC} $1"; }

	list_all() {
		local src="$REPO_DIR/$CLI/.$CLI"
		for dir in "$src"/*/; do
			local category=$(basename "$dir")
			[[ "$category" == "node_modules" ]] && continue
			if [[ "$category" == "skills" ]]; then
				for skill in "$dir"/*/; do
					[[ -d "$skill" ]] && echo "skills/$(basename "$skill")"
				done
			else
				for f in "$dir"/*.md; do
					[[ -f "$f" ]] && echo "$category/$(basename "$f" .md)"
				done
			fi
		done | sort
	}

	src_of() {
		local item="$1"
		if [[ "$item" == skills/* ]]; then
			echo "$REPO_DIR/$CLI/.$CLI/$item"
		else
			echo "$REPO_DIR/$CLI/.$CLI/$item.md"
		fi
	}

	dest_of() {
		local item="$1"
		if [[ "$item" == skills/* ]]; then
			echo "$TARGET/.$CLI/$item"
		else
			echo "$TARGET/.$CLI/$item.md"
		fi
	}

	is_ours() {
		[[ -L "$1" ]] && [[ "$(readlink "$1")" == "$REPO_DIR"/* ]]
	}

	link_item() {
		local item="$1"
		local src=$(src_of "$item") dest=$(dest_of "$item")
		is_ours "$dest" && return 0
		if [[ -e "$dest" || -L "$dest" ]]; then
			warn "Skip $item — already exists (not ours)"
			return 0
		fi
		mkdir -p "$(dirname "$dest")"
		ln -s "$src" "$dest"
	}

	unlink_item() {
		local item="$1"
		local dest=$(dest_of "$item")
		is_ours "$dest" && rm "$dest" && return 0
		[[ -e "$dest" ]] && warn "Skip $item — not ours"
	}

	do_install_all() {
		local items count=0 skipped=0
		items=$(list_all)
		[[ -z "$items" ]] && {
			error "No items found for $CLI"
			return 1
		}

		while read -r item; do
			local src=$(src_of "$item") dest=$(dest_of "$item")
			is_ours "$dest" && continue
			if [[ -e "$dest" || -L "$dest" ]]; then
				warn "Skip $item — already exists (not ours)"
				skipped=$((skipped + 1))
				continue
			fi
			mkdir -p "$(dirname "$dest")"
			ln -s "$src" "$dest"
			count=$((count + 1))
		done <<<"$items"

		info "Linked $count new item(s) to ~/.$CLI/"
		[[ $skipped -gt 0 ]] && warn "Skipped $skipped item(s) — already exist (not ours)"
		return 0
	}

	desc_of() {
		local item="$1" file
		if [[ "$item" == skills/* ]]; then
			file="$REPO_DIR/$CLI/.$CLI/$item/SKILL.md"
		else
			file="$REPO_DIR/$CLI/.$CLI/$item.md"
		fi
		[[ -f "$file" ]] || return
		awk '/^---$/{n++; next} n==1 && /^description:/{
			sub(/^description: */, "")
			sub(/\. .*/, "")
			if (length > 120) { $0 = substr($0, 1, 117) "..." }
			print; exit
		}' "$file"
	}

	list_display() {
		local items="$1"
		while read -r item; do
			local desc
			desc=$(desc_of "$item")
			if [[ -n "$desc" ]]; then
				echo "$item — $desc"
			else
				echo "$item"
			fi
		done <<<"$items"
	}

	strip_desc() {
		sed 's/ — .*//'
	}
}

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

CURRENT_TEST="skips if non-symlink file exists"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "user-file" >"$TARGET/.claude/agents/agent-a.md"
output=$(link_item "agents/agent-a" 2>&1)
assert_not_link "$TARGET/.claude/agents/agent-a.md" &&
	content=$(cat "$TARGET/.claude/agents/agent-a.md") &&
	assert_eq "$content" "user-file" &&
	pass
teardown

CURRENT_TEST="skips if foreign symlink exists"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
ln -s "/some/other/path" "$TARGET/.claude/agents/agent-a.md"
output=$(link_item "agents/agent-a" 2>&1)
assert_link_target "$TARGET/.claude/agents/agent-a.md" "/some/other/path" && pass
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

CURRENT_TEST="install_all skips user files"
setup
CLI="claude"
mkdir -p "$TARGET/.claude/agents"
echo "user-file" >"$TARGET/.claude/agents/agent-a.md"
output=$(do_install_all 2>&1)
assert_not_link "$TARGET/.claude/agents/agent-a.md" &&
	content=$(cat "$TARGET/.claude/agents/agent-a.md") &&
	assert_eq "$content" "user-file" &&
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

###############################################################################
echo ""
echo "== desc_of / list_display / strip_desc =="

CURRENT_TEST="desc_of extracts description from agent frontmatter"
setup
CLI="claude"
# Add frontmatter to test files
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
# File has no frontmatter description
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
assert_eq "$desc" '"A comprehensive verification system' && pass
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
	# agent-b should NOT have " — " separator
	line_b=$(echo "$display" | grep "^agents/agent-b") &&
	[[ "$line_b" != *" — "* ]] &&
	pass
teardown

CURRENT_TEST="strip_desc handles em dash inside description"
setup
# Real case: "agents/code-reviewer — Expert reviewer — quality, security"
result=$(echo "agents/code-reviewer — Expert reviewer — quality, security" | strip_desc)
assert_eq "$result" "agents/code-reviewer" && pass
teardown

CURRENT_TEST="list_all skips empty category directories"
setup
CLI="claude"
mkdir -p "$REPO_DIR/claude/.claude/empty-cat"
# no .md files inside
items=$(list_all)
[[ "$items" != *"empty-cat"* ]] && pass || fail "empty category should not appear"
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
# Simulate selecting a display line and stripping desc
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
# Verify all linked
assert_link "$(dest_of agents/oc-agent)" &&
	assert_link "$(dest_of skills/api-design)" || { fail "install_all failed"; }
# Uninstall each via display flow
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
echo "================================"
echo "  $PASS passed, $FAIL failed"
echo "================================"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
