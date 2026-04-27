use std::path::{Path, PathBuf};

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct Item {
    pub category: String,
    pub name: String,
}

impl Item {
    /// "skills/caveman" -> Item { category: "skills", name: "caveman" }
    #[allow(dead_code)]
    pub fn parse(s: &str) -> Option<Item> {
        let (category, name) = s.split_once('/')?;
        Some(Item {
            category: category.to_string(),
            name: name.to_string(),
        })
    }

    /// "skills/caveman"
    pub fn id(&self) -> String {
        format!("{}/{}", self.category, self.name)
    }

    /// repo_dir/<cli>/.<cli>/<category>/<name>[.md]
    pub fn src_path(&self, repo_dir: &Path, cli: &str) -> PathBuf {
        let base = repo_dir
            .join(cli)
            .join(format!(".{cli}"))
            .join(&self.category);
        if self.category == "skills" {
            base.join(&self.name)
        } else {
            base.join(format!("{}.md", self.name))
        }
    }

    pub fn dest_path(&self, target: &Path, cli: &str) -> PathBuf {
        let base = target.join(format!(".{cli}")).join(&self.category);
        if self.category == "skills" {
            base.join(&self.name)
        } else {
            base.join(format!("{}.md", self.name))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn parse_splits_category_and_name() {
        let it = Item::parse("skills/caveman").unwrap();
        assert_eq!(it.category, "skills");
        assert_eq!(it.name, "caveman");
    }

    #[test]
    fn parse_returns_none_on_invalid() {
        assert!(Item::parse("no-slash").is_none());
    }

    #[test]
    fn id_roundtrip() {
        let it = Item { category: "agents".into(), name: "code-reviewer".into() };
        assert_eq!(it.id(), "agents/code-reviewer");
    }

    #[test]
    fn src_path_skill_is_dir() {
        let it = Item { category: "skills".into(), name: "caveman".into() };
        let p = it.src_path(&PathBuf::from("/repo"), "opencode");
        assert_eq!(p, PathBuf::from("/repo/opencode/.opencode/skills/caveman"));
    }

    #[test]
    fn src_path_command_is_md_file() {
        let it = Item { category: "commands".into(), name: "caveman".into() };
        let p = it.src_path(&PathBuf::from("/repo"), "claude");
        assert_eq!(p, PathBuf::from("/repo/claude/.claude/commands/caveman.md"));
    }

    #[test]
    fn dest_path_skill_under_home() {
        let it = Item { category: "skills".into(), name: "caveman".into() };
        let p = it.dest_path(&PathBuf::from("/home/u"), "opencode");
        assert_eq!(p, PathBuf::from("/home/u/.opencode/skills/caveman"));
    }

    #[test]
    fn dest_path_command_is_md() {
        let it = Item { category: "commands".into(), name: "caveman".into() };
        let p = it.dest_path(&PathBuf::from("/home/u"), "claude");
        assert_eq!(p, PathBuf::from("/home/u/.claude/commands/caveman.md"));
    }
}
