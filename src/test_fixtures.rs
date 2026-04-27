//! Helpers partagés pour les tests — compilé uniquement en mode test.
use std::fs;
use std::path::{Path, PathBuf};
use tempfile::TempDir;

pub struct Fixture {
    pub tmp: TempDir,
}

impl Fixture {
    /// Crée un faux repo avec structure claude/.claude et opencode/.opencode.
    pub fn new() -> Self {
        let tmp = TempDir::new().unwrap();
        let f = Fixture { tmp };

        // claude
        f.write_cmd("claude", "commands", "caveman", "Caveman mode", "body 1");
        f.write_cmd(
            "claude",
            "commands",
            "postgres-patterns",
            "PG patterns",
            "body pg",
        );
        f.write_cmd(
            "claude",
            "agents",
            "code-reviewer",
            "Reviews code",
            "Agent doc.\n\nSee ~/.claude/commands/caveman.md",
        );

        // opencode
        f.write_cmd(
            "opencode",
            "commands",
            "api-design",
            "API design",
            "body api",
        );
        f.write_skill("opencode", "caveman", "Caveman skill", "skill body");
        f.write_skill("opencode", "api-design", "API design skill", "skill body");
        f.write_cmd(
            "opencode",
            "agents",
            "frontend-developer",
            "FE dev",
            "Agent.\n\nSee ~/.opencode/skills/caveman/SKILL.md",
        );

        f
    }

    pub fn repo(&self) -> &Path {
        self.tmp.path()
    }

    pub fn target(&self) -> PathBuf {
        let t = self.tmp.path().join("home");
        fs::create_dir_all(&t).unwrap();
        t
    }

    fn write_cmd(&self, cli: &str, category: &str, name: &str, desc: &str, body: &str) {
        let dir = self
            .tmp
            .path()
            .join(cli)
            .join(format!(".{cli}"))
            .join(category);
        fs::create_dir_all(&dir).unwrap();
        let content = format!("---\nname: {name}\ndescription: {desc}\n---\n\n{body}\n");
        fs::write(dir.join(format!("{name}.md")), content).unwrap();
    }

    fn write_skill(&self, cli: &str, name: &str, desc: &str, body: &str) {
        let dir = self
            .tmp
            .path()
            .join(cli)
            .join(format!(".{cli}"))
            .join("skills")
            .join(name);
        fs::create_dir_all(&dir).unwrap();
        let content = format!("---\nname: {name}\ndescription: {desc}\n---\n\n{body}\n");
        fs::write(dir.join("SKILL.md"), content).unwrap();
    }
}
