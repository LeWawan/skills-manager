use anyhow::{Context, Result};
use std::collections::HashSet;
use std::fs;
use std::path::Path;

/// Convertit toutes les commandes Claude en skills OpenCode.
/// - Parse frontmatter (name, description)
/// - Génère SKILL.md avec frontmatter étendu + body
/// - Supprime skills orphelins (plus de commande source)
/// Skip: fichiers `shape-up*` (gérés séparément).
pub fn run(repo_dir: &Path) -> Result<()> {
    let src_dir = repo_dir.join("claude/.claude/commands");
    let dst_dir = repo_dir.join("opencode/.opencode/skills");
    fs::create_dir_all(&dst_dir)?;

    let mut expected: HashSet<String> = HashSet::new();

    for entry in fs::read_dir(&src_dir)
        .with_context(|| format!("read {}", src_dir.display()))?
    {
        let entry = entry?;
        let path = entry.path();
        if path.extension().map(|e| e != "md").unwrap_or(true) {
            continue;
        }
        let Some(stem) = path.file_stem().and_then(|s| s.to_str()) else {
            continue;
        };
        if stem.starts_with("shape-up") {
            continue;
        }

        expected.insert(stem.to_string());

        let content = fs::read_to_string(&path)?;
        let (name, description, body) = parse_command(&content);
        let name = name.unwrap_or_else(|| stem.to_string());

        let skill_dir = dst_dir.join(stem);
        fs::create_dir_all(&skill_dir)?;

        let skill_md = format!(
            "---\n\
             name: {name}\n\
             description: {desc}\n\
             license: MIT\n\
             compatibility: opencode\n\
             metadata:\n  \
             origin: claude-skills\n  \
             type: workflow\n\
             ---\n\n\
             {body}",
            desc = description.unwrap_or_default(),
            body = body,
        );
        fs::write(skill_dir.join("SKILL.md"), skill_md)?;
        println!("✓ Created skill: {stem}");
    }

    // Prune orphans
    for entry in fs::read_dir(&dst_dir)? {
        let entry = entry?;
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }
        let Some(name) = path.file_name().and_then(|s| s.to_str()) else {
            continue;
        };
        if !expected.contains(name) {
            fs::remove_dir_all(&path)?;
            println!("✗ Removed orphan skill: {name}");
        }
    }

    println!("\nConversion complete! Skills created in {}", dst_dir.display());
    Ok(())
}

/// Parse un fichier markdown avec frontmatter YAML.
/// Retourne: (name, description, body).
fn parse_command(content: &str) -> (Option<String>, Option<String>, String) {
    let mut name: Option<String> = None;
    let mut description: Option<String> = None;
    let mut body = String::new();
    let mut fm_state = 0u8; // 0: avant, 1: dans FM, 2: après

    for line in content.lines() {
        if line.trim() == "---" {
            fm_state += 1;
            continue;
        }
        match fm_state {
            1 => {
                if let Some(v) = line.strip_prefix("name:") {
                    name = Some(v.trim().to_string());
                } else if let Some(v) = line.strip_prefix("description:") {
                    description = Some(v.trim().to_string());
                }
            }
            2 => {
                body.push_str(line);
                body.push('\n');
            }
            _ => {}
        }
    }
    (name, description, body)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_command_extracts_fields() {
        let c = "---\nname: foo\ndescription: bar\n---\n\nhello body\n";
        let (name, desc, body) = parse_command(c);
        assert_eq!(name.as_deref(), Some("foo"));
        assert_eq!(desc.as_deref(), Some("bar"));
        assert!(body.contains("hello body"));
    }

    #[test]
    fn parse_command_missing_frontmatter() {
        let c = "plain text\n";
        let (name, desc, body) = parse_command(c);
        assert!(name.is_none());
        assert!(desc.is_none());
        assert!(body.is_empty());
    }

    #[test]
    fn run_creates_skill_from_command() {
        let tmp = tempfile::TempDir::new().unwrap();
        let repo = tmp.path();
        let cmd_dir = repo.join("claude/.claude/commands");
        fs::create_dir_all(&cmd_dir).unwrap();
        fs::write(
            cmd_dir.join("my-cmd.md"),
            "---\nname: my-cmd\ndescription: test\n---\n\nbody.\n",
        )
        .unwrap();

        run(repo).unwrap();

        let skill = repo.join("opencode/.opencode/skills/my-cmd/SKILL.md");
        assert!(skill.exists());
        let content = fs::read_to_string(&skill).unwrap();
        assert!(content.contains("name: my-cmd"));
        assert!(content.contains("license: MIT"));
        assert!(content.contains("body."));
    }

    #[test]
    fn run_prunes_orphan_skills() {
        let tmp = tempfile::TempDir::new().unwrap();
        let repo = tmp.path();
        fs::create_dir_all(repo.join("claude/.claude/commands")).unwrap();
        let orphan = repo.join("opencode/.opencode/skills/orphan");
        fs::create_dir_all(&orphan).unwrap();
        fs::write(orphan.join("SKILL.md"), "old").unwrap();

        run(repo).unwrap();
        assert!(!orphan.exists());
    }

    #[test]
    fn run_skips_shape_up_files() {
        let tmp = tempfile::TempDir::new().unwrap();
        let repo = tmp.path();
        let cmd_dir = repo.join("claude/.claude/commands");
        fs::create_dir_all(&cmd_dir).unwrap();
        fs::write(cmd_dir.join("shape-up.md"), "---\nname: shape-up\n---\nx").unwrap();

        run(repo).unwrap();
        assert!(!repo.join("opencode/.opencode/skills/shape-up").exists());
    }
}
