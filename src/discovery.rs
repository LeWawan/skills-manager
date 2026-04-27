use crate::item::Item;
use anyhow::Result;
use std::collections::HashSet;
use std::fs;
use std::path::Path;

/// Items qui restent visibles même si référencés par un agent.
pub const STANDALONE: &[&str] = &[
    "caveman",
    "coding-standards",
    "security-review",
    "docker-patterns",
    "tdd-workflow",
    "verification-loop",
    "deep-research",
];

/// Walk `repo_dir/<cli>/.<cli>/*` — retourne tous les items, triés par id.
pub fn list_all(repo_dir: &Path, cli: &str) -> Result<Vec<Item>> {
    let src = repo_dir.join(cli).join(format!(".{cli}"));
    let mut items: Vec<Item> = Vec::new();

    for entry in fs::read_dir(&src)? {
        let entry = entry?;
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }

        let category = entry.file_name().to_string_lossy().to_string();
        if category == "node_modules" {
            continue;
        }

        if category == "skills" {
            for skill in fs::read_dir(&path)? {
                let skill = skill?;
                if skill.path().is_dir() {
                    items.push(Item {
                        category: category.clone(),
                        name: skill.file_name().to_string_lossy().to_string(),
                    });
                }
            }
        } else {
            for file in fs::read_dir(&path)? {
                let file = file?;
                let fpath = file.path();
                if fpath.extension().map(|e| e == "md").unwrap_or(false) {
                    let name = fpath.file_stem().unwrap().to_string_lossy().to_string();
                    items.push(Item {
                        category: category.clone(),
                        name,
                    });
                }
            }
        }
    }

    items.sort_by(|a, b| a.id().cmp(&b.id()));
    Ok(items)
}

/// Extrait `description:` du frontmatter YAML. Première phrase, max 120 chars.
pub fn desc_of(repo_dir: &Path, cli: &str, item: &Item) -> Option<String> {
    let file = if item.category == "skills" {
        item.src_path(repo_dir, cli).join("SKILL.md")
    } else {
        item.src_path(repo_dir, cli)
    };
    let content = fs::read_to_string(&file).ok()?;

    let mut in_frontmatter = 0;
    for line in content.lines() {
        if line.trim() == "---" {
            in_frontmatter += 1;
            if in_frontmatter == 2 {
                return None;
            }
            continue;
        }
        if in_frontmatter == 1 {
            if let Some(rest) = line.strip_prefix("description:") {
                let mut s = rest.trim().to_string();
                // trim quotes éventuelles
                s = s
                    .trim_start_matches(|c| c == '"' || c == '\'')
                    .trim_end_matches(|c| c == '"' || c == '\'')
                    .to_string();
                // première phrase
                if let Some(idx) = s.find(". ") {
                    s.truncate(idx);
                }
                let s = s.replace(',', ";");
                let s = if s.len() > 120 {
                    format!("{}...", &s[..117])
                } else {
                    s
                };
                return Some(s);
            }
        }
    }
    None
}

/// Agents seulement: extrait deps depuis le markdown (refs ~/.claude/commands/... ou ~/.opencode/skills/.../SKILL.md).
pub fn deps_of(repo_dir: &Path, cli: &str, item: &Item) -> Vec<Item> {
    if item.category != "agents" {
        return Vec::new();
    }
    let file = item.src_path(repo_dir, cli);
    let Ok(content) = fs::read_to_string(&file) else {
        return Vec::new();
    };

    let mut out = Vec::new();
    if cli == "claude" {
        // ~/.claude/commands/<name>.md
        for cap in content.split("~/.claude/commands/").skip(1) {
            if let Some(end) = cap.find(|c: char| c == '`' || c.is_whitespace()) {
                let raw = &cap[..end];
                if let Some(name) = raw.strip_suffix(".md") {
                    out.push(Item {
                        category: "commands".into(),
                        name: name.into(),
                    });
                }
            }
        }
    } else {
        // ~/.opencode/skills/<name>/SKILL.md
        for cap in content.split("~/.opencode/skills/").skip(1) {
            if let Some(end) = cap.find("/SKILL.md") {
                out.push(Item {
                    category: "skills".into(),
                    name: cap[..end].to_string(),
                });
            }
        }
    }
    out
}

/// Tous les deps de tous les agents, uniques.
pub fn all_agent_deps(repo_dir: &Path, cli: &str, all: &[Item]) -> HashSet<String> {
    let mut set = HashSet::new();
    for item in all.iter().filter(|i| i.category == "agents") {
        for dep in deps_of(repo_dir, cli, item) {
            set.insert(dep.name);
        }
    }
    set
}

// PARTIE 2/3 A TOI — is_standalone.
// Signature: pub fn is_standalone(item: &Item) -> bool
// Logique: retourne true si `item.name` est dans la const STANDALONE.
// Astuce: `STANDALONE.contains(&item.name.as_str())` — note le `&` + `.as_str()`.
// (STANDALONE contient des &str, on compare avec des &str)
pub fn is_standalone(item: &Item) -> bool {
    STANDALONE.contains(&item.name.as_str())
}

/// Filtre items visibles dans le selector.
pub fn list_visible(repo_dir: &Path, cli: &str, all: &[Item]) -> Vec<Item> {
    let deps = all_agent_deps(repo_dir, cli, all);
    let mut out = Vec::new();
    for item in all {
        // agents: toujours visible
        if item.category == "agents" {
            out.push(item.clone());
            continue;
        }
        // opencode: cache skills/<X> si commands/<X> existe
        if cli == "opencode" && item.category == "skills" {
            let pair = Item {
                category: "commands".into(),
                name: item.name.clone(),
            };
            if pair.src_path(repo_dir, cli).exists() {
                continue;
            }
        }
        if is_standalone(item) {
            out.push(item.clone());
            continue;
        }
        if !deps.contains(&item.name) {
            out.push(item.clone());
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test_fixtures::Fixture;

    #[test]
    fn list_all_finds_claude_items() {
        let f = Fixture::new();
        let items = list_all(f.repo(), "claude").unwrap();
        let ids: Vec<_> = items.iter().map(|i| i.id()).collect();
        assert!(ids.contains(&"commands/caveman".to_string()));
        assert!(ids.contains(&"agents/code-reviewer".to_string()));
        assert!(ids.contains(&"commands/postgres-patterns".to_string()));
    }

    #[test]
    fn list_all_finds_opencode_skills_as_dirs() {
        let f = Fixture::new();
        let items = list_all(f.repo(), "opencode").unwrap();
        let ids: Vec<_> = items.iter().map(|i| i.id()).collect();
        assert!(ids.contains(&"skills/caveman".to_string()));
        assert!(ids.contains(&"skills/api-design".to_string()));
    }

    #[test]
    fn list_all_sorted_by_id() {
        let f = Fixture::new();
        let items = list_all(f.repo(), "claude").unwrap();
        let ids: Vec<_> = items.iter().map(|i| i.id()).collect();
        let mut sorted = ids.clone();
        sorted.sort();
        assert_eq!(ids, sorted);
    }

    #[test]
    fn desc_of_extracts_description() {
        let f = Fixture::new();
        let it = Item { category: "commands".into(), name: "caveman".into() };
        let desc = desc_of(f.repo(), "claude", &it).unwrap();
        assert_eq!(desc, "Caveman mode");
    }

    #[test]
    fn desc_of_none_for_missing_file() {
        let f = Fixture::new();
        let it = Item { category: "commands".into(), name: "nope".into() };
        assert!(desc_of(f.repo(), "claude", &it).is_none());
    }

    #[test]
    fn deps_of_parses_claude_agent() {
        let f = Fixture::new();
        let agent = Item { category: "agents".into(), name: "code-reviewer".into() };
        let deps = deps_of(f.repo(), "claude", &agent);
        assert_eq!(deps.len(), 1);
        assert_eq!(deps[0].id(), "commands/caveman");
    }

    #[test]
    fn deps_of_parses_opencode_agent() {
        let f = Fixture::new();
        let agent = Item { category: "agents".into(), name: "frontend-developer".into() };
        let deps = deps_of(f.repo(), "opencode", &agent);
        assert_eq!(deps.len(), 1);
        assert_eq!(deps[0].id(), "skills/caveman");
    }

    #[test]
    fn deps_of_empty_for_non_agent() {
        let f = Fixture::new();
        let it = Item { category: "commands".into(), name: "caveman".into() };
        assert!(deps_of(f.repo(), "claude", &it).is_empty());
    }

    #[test]
    fn is_standalone_matches_const() {
        let it = Item { category: "commands".into(), name: "caveman".into() };
        assert!(is_standalone(&it));
    }

    #[test]
    fn is_standalone_false_for_other() {
        let it = Item { category: "commands".into(), name: "postgres-patterns".into() };
        assert!(!is_standalone(&it));
    }

    #[test]
    fn list_visible_hides_deps_but_keeps_standalone() {
        let f = Fixture::new();
        let all = list_all(f.repo(), "claude").unwrap();
        let visible = list_visible(f.repo(), "claude", &all);
        let ids: Vec<_> = visible.iter().map(|i| i.id()).collect();
        // caveman est dep de code-reviewer MAIS standalone → visible
        assert!(ids.contains(&"commands/caveman".to_string()));
        // agent toujours visible
        assert!(ids.contains(&"agents/code-reviewer".to_string()));
    }

    #[test]
    fn list_visible_opencode_hides_skill_when_command_exists() {
        let f = Fixture::new();
        let all = list_all(f.repo(), "opencode").unwrap();
        let visible = list_visible(f.repo(), "opencode", &all);
        let ids: Vec<_> = visible.iter().map(|i| i.id()).collect();
        // skills/api-design caché car commands/api-design existe
        assert!(!ids.contains(&"skills/api-design".to_string()));
        assert!(ids.contains(&"commands/api-design".to_string()));
    }
}
