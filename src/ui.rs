use crate::discovery::{self, deps_of};
use crate::item::Item;
use crate::link::{self, LinkOutcome};
use anyhow::Result;
use inquire::{Confirm, MultiSelect, Select};
use std::collections::HashSet;
use std::fmt;
use std::path::Path;

/// Wrapper pour affichage dans les selectors inquire.
#[derive(Clone)]
pub struct Choice {
    pub item: Item,
    pub label: String,
}

impl fmt::Display for Choice {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.label)
    }
}

fn build_choice(repo_dir: &Path, cli: &str, item: Item) -> Choice {
    let label = match discovery::desc_of(repo_dir, cli, &item) {
        Some(desc) => format!("{} — {}", item.id(), desc),
        None => item.id(),
    };
    Choice { item, label }
}

fn confirm_fn(msg: &str) -> bool {
    Confirm::new(msg)
        .with_default(false)
        .prompt()
        .unwrap_or(false)
}

pub fn pick_cli() -> Result<Option<String>> {
    let choice = Select::new("Select CLI:", vec!["claude", "opencode"]).prompt_skippable()?;
    Ok(choice.map(|s| s.to_string()))
}

#[derive(Clone, Copy, Debug)]
pub enum Action {
    Install,
    InstallAll,
    Uninstall,
}

impl fmt::Display for Action {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(match self {
            Action::Install => "Install",
            Action::InstallAll => "Install all",
            Action::Uninstall => "Uninstall",
        })
    }
}

pub fn pick_action() -> Result<Option<Action>> {
    let opts = vec![Action::Install, Action::InstallAll, Action::Uninstall];
    Ok(Select::new("Action:", opts).prompt_skippable()?)
}

/// Déduplique en préservant l'ordre d'insertion.
fn dedup(items: Vec<Item>) -> Vec<Item> {
    let mut seen = HashSet::new();
    let mut out = Vec::new();
    for it in items {
        if seen.insert(it.id()) {
            out.push(it);
        }
    }
    out
}

/// Résout deps d'agents + pairs commands/skills pour opencode.
fn resolve_deps(repo_dir: &Path, cli: &str, selected: Vec<Item>) -> Vec<Item> {
    let mut resolved = Vec::new();
    for item in selected {
        if item.category == "agents" {
            for dep in deps_of(repo_dir, cli, &item) {
                resolved.push(dep);
            }
        } else if cli == "opencode" && item.category == "commands" {
            let pair = Item {
                category: "skills".into(),
                name: item.name.clone(),
            };
            if pair.src_path(repo_dir, cli).exists() {
                resolved.push(pair);
            }
        }
        resolved.push(item);
    }
    dedup(resolved)
}

pub fn install(repo_dir: &Path, target: &Path, cli: &str) -> Result<()> {
    let all = discovery::list_all(repo_dir, cli)?;
    let visible = discovery::list_visible(repo_dir, cli, &all);
    if visible.is_empty() {
        println!("[warn] No items found for {cli}");
        return Ok(());
    }

    let choices: Vec<Choice> = visible
        .into_iter()
        .map(|it| build_choice(repo_dir, cli, it))
        .collect();

    // pré-sélectionne les déjà installés
    let default_idx: Vec<usize> = choices
        .iter()
        .enumerate()
        .filter(|(_, c)| link::is_ours(&c.item.dest_path(target, cli), repo_dir))
        .map(|(i, _)| i)
        .collect();

    let selected = MultiSelect::new("Select items to install:", choices)
        .with_default(&default_idx)
        .prompt_skippable()?;
    let Some(selected) = selected else {
        println!("[warn] Nothing selected.");
        return Ok(());
    };

    let picked: Vec<Item> = selected.into_iter().map(|c| c.item).collect();
    let resolved = resolve_deps(repo_dir, cli, picked);

    let mut count = 0;
    for item in &resolved {
        match link::link_item(item, repo_dir, target, cli, &confirm_fn)? {
            LinkOutcome::Linked | LinkOutcome::Migrated => count += 1,
            LinkOutcome::AlreadyOurs => {}
            LinkOutcome::Aborted => {
                println!("[info] Aborted by user.");
                return Ok(());
            }
        }
    }
    println!("[info] Linked {count} new item(s) to ~/.{cli}/");
    Ok(())
}

pub fn install_all(repo_dir: &Path, target: &Path, cli: &str) -> Result<()> {
    let all = discovery::list_all(repo_dir, cli)?;
    if all.is_empty() {
        println!("[warn] No items found for {cli}");
        return Ok(());
    }

    let mut count = 0;
    for item in &all {
        match link::link_item(item, repo_dir, target, cli, &confirm_fn)? {
            LinkOutcome::Linked | LinkOutcome::Migrated | LinkOutcome::AlreadyOurs => count += 1,
            LinkOutcome::Aborted => {
                println!("[info] Aborted by user.");
                return Ok(());
            }
        }
    }
    println!("[info] Linked {count} item(s) to ~/.{cli}/");
    Ok(())
}

pub fn uninstall(repo_dir: &Path, target: &Path, cli: &str) -> Result<()> {
    let all = discovery::list_all(repo_dir, cli)?;
    let installed: Vec<Item> = all
        .into_iter()
        .filter(|it| link::is_ours(&it.dest_path(target, cli), repo_dir))
        .collect();
    if installed.is_empty() {
        println!("[warn] Nothing installed.");
        return Ok(());
    }

    let choices: Vec<Choice> = installed
        .into_iter()
        .map(|it| build_choice(repo_dir, cli, it))
        .collect();
    let default_idx: Vec<usize> = (0..choices.len()).collect();

    let selected = MultiSelect::new("Select items to uninstall:", choices)
        .with_default(&default_idx)
        .prompt_skippable()?;
    let Some(selected) = selected else {
        println!("[warn] Nothing selected.");
        return Ok(());
    };

    let mut count = 0;
    for c in selected {
        if link::unlink_item(&c.item, repo_dir, target, cli)? {
            count += 1;
        }
    }
    println!("[info] Removed {count} item(s) from ~/.{cli}/");
    Ok(())
}

pub fn run(repo_dir: &Path, target: &Path) -> Result<()> {
    println!("=== Skills Manager ===\n");
    let Some(cli) = pick_cli()? else {
        return Ok(());
    };
    let Some(action) = pick_action()? else {
        return Ok(());
    };
    match action {
        Action::Install => install(repo_dir, target, &cli),
        Action::InstallAll => install_all(repo_dir, target, &cli),
        Action::Uninstall => uninstall(repo_dir, target, &cli),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test_fixtures::Fixture;

    fn it(category: &str, name: &str) -> Item {
        Item {
            category: category.into(),
            name: name.into(),
        }
    }

    #[test]
    fn dedup_preserves_order_and_removes_duplicates() {
        let input = vec![
            it("agents", "x"),
            it("commands", "a"),
            it("agents", "x"),
            it("commands", "b"),
            it("commands", "a"),
        ];
        let out = dedup(input);
        let ids: Vec<_> = out.iter().map(|i| i.id()).collect();
        assert_eq!(ids, vec!["agents/x", "commands/a", "commands/b"]);
    }

    #[test]
    fn resolve_deps_adds_agent_deps_before_agent() {
        let f = Fixture::new();
        let agent = it("agents", "code-reviewer");
        let out = resolve_deps(f.repo(), "claude", vec![agent.clone()]);
        let ids: Vec<_> = out.iter().map(|i| i.id()).collect();
        // dep avant agent, agent après
        assert_eq!(ids, vec!["commands/caveman", "agents/code-reviewer"]);
    }

    #[test]
    fn resolve_deps_pairs_opencode_command_with_skill() {
        let f = Fixture::new();
        let cmd = it("commands", "api-design");
        let out = resolve_deps(f.repo(), "opencode", vec![cmd]);
        let ids: Vec<_> = out.iter().map(|i| i.id()).collect();
        assert!(ids.contains(&"skills/api-design".to_string()));
        assert!(ids.contains(&"commands/api-design".to_string()));
    }

    #[test]
    fn resolve_deps_no_pair_when_skill_missing() {
        let f = Fixture::new();
        let cmd = it("commands", "no-skill-for-me");
        let out = resolve_deps(f.repo(), "opencode", vec![cmd]);
        let ids: Vec<_> = out.iter().map(|i| i.id()).collect();
        assert_eq!(ids, vec!["commands/no-skill-for-me"]);
    }

    #[test]
    fn resolve_deps_does_not_pair_for_claude() {
        let f = Fixture::new();
        let cmd = it("commands", "caveman");
        let out = resolve_deps(f.repo(), "claude", vec![cmd.clone()]);
        let ids: Vec<_> = out.iter().map(|i| i.id()).collect();
        assert_eq!(ids, vec!["commands/caveman"]);
    }

    #[test]
    fn resolve_deps_dedups_when_user_already_picked_dep() {
        let f = Fixture::new();
        let dep = it("commands", "caveman");
        let agent = it("agents", "code-reviewer");
        // user a coché les deux manuellement
        let out = resolve_deps(f.repo(), "claude", vec![dep, agent]);
        let ids: Vec<_> = out.iter().map(|i| i.id()).collect();
        assert_eq!(ids.iter().filter(|i| *i == "commands/caveman").count(), 1);
    }

    #[test]
    fn build_choice_includes_description() {
        let f = Fixture::new();
        let c = build_choice(f.repo(), "claude", it("commands", "caveman"));
        assert!(c.label.contains("commands/caveman"));
        assert!(c.label.contains("—"));
        assert!(c.label.contains("Caveman mode"));
    }

    #[test]
    fn build_choice_no_dash_when_no_description() {
        let f = Fixture::new();
        let c = build_choice(f.repo(), "claude", it("commands", "missing-file"));
        assert_eq!(c.label, "commands/missing-file");
    }
}
