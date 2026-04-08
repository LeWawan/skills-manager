#!/usr/bin/env bash
# Convert Claude commands to OpenCode skills

set -e

CLAUDE_COMMANDS_DIR="claude/.claude/commands"
OPENCODE_SKILLS_DIR="opencode/.opencode/skills"

# Ensure skills directory exists
mkdir -p "$OPENCODE_SKILLS_DIR"

# Process each command file
for cmd_file in "$CLAUDE_COMMANDS_DIR"/*.md; do
	# Get filename without extension
	basename=$(basename "$cmd_file" .md)

	# Skip if it's a shape-up file (handled separately)
	if [[ "$basename" == shape-up* ]]; then
		continue
	fi

	# Create skill directory
	skill_dir="$OPENCODE_SKILLS_DIR/$basename"
	mkdir -p "$skill_dir"

	# Extract frontmatter fields
	name=$(grep "^name:" "$cmd_file" | sed 's/name: *//')
	description=$(grep "^description:" "$cmd_file" | sed 's/description: *//')

	# Create SKILL.md with proper frontmatter
	cat >"$skill_dir/SKILL.md" <<EOF
---
name: $name
description: $description
license: MIT
compatibility: opencode
metadata:
  origin: claude-skills
  type: workflow
---

$(awk 'BEGIN{p=0} /^---$/{p++; next} p==2{print}' "$cmd_file")
EOF

	echo "✓ Created skill: $basename"
done

echo ""
echo "Conversion complete! Skills created in $OPENCODE_SKILLS_DIR"
