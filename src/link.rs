use crate::item::Item;
use anyhow::{Context, Result};
use std::fs;
use std::os::unix::fs as unix_fs;
use std::path::Path;

/// Résultat d'une opération de link pour permettre au caller de compter/abort.
#[derive(Debug, PartialEq)]
pub enum LinkOutcome {
    Linked,       // nouveau symlink créé
    AlreadyOurs,  // déjà un symlink vers nous
    Migrated,     // remplacé un fichier existant
    Aborted,      // user a refusé la migration
}

pub fn is_ours(dest: &Path, repo_dir: &Path) -> bool {
    if !dest.is_symlink() {
        return false;
    }
    let Ok(target) = fs::read_link(dest) else {
        return false;
    };
    // Fast path: symlink points into the current catalogue.
    if target.starts_with(repo_dir) {
        return true;
    }
    // Fallback: any symlink pointing into a recognisable catalogue layout
    // counts as ours. Makes installs survive moving the catalogue or
    // switching between a dev clone (cargo run) and the bundled binary.
    let s = target.to_string_lossy();
    let in_catalog = s.contains("/claude/.claude/") || s.contains("/opencode/.opencode/");
    in_catalog && target.exists()
}

/// Compare contenu de deux chemins (fichier ou dir récursif).
pub fn content_matches(a: &Path, b: &Path) -> Result<bool> {
    if a.is_dir() && b.is_dir() {
        dirs_equal(a, b)
    } else if a.is_file() && b.is_file() {
        Ok(fs::read(a)? == fs::read(b)?)
    } else {
        Ok(false)
    }
}

fn dirs_equal(a: &Path, b: &Path) -> Result<bool> {
    let mut a_entries: Vec<_> = fs::read_dir(a)?
        .filter_map(|e| e.ok())
        .map(|e| e.file_name())
        .collect();
    let mut b_entries: Vec<_> = fs::read_dir(b)?
        .filter_map(|e| e.ok())
        .map(|e| e.file_name())
        .collect();
    a_entries.sort();
    b_entries.sort();
    if a_entries != b_entries {
        return Ok(false);
    }
    for name in a_entries {
        let ap = a.join(&name);
        let bp = b.join(&name);
        if !content_matches(&ap, &bp)? {
            return Ok(false);
        }
    }
    Ok(true)
}

/// Si le parent de `dest` est un symlink vers notre repo, le "déplie" —
/// remplace le symlink par un vrai dir avec le contenu copié. Nécessaire
/// pour pouvoir gérer des symlinks individuels par item sans corrompre le repo.
pub fn unfold_dir(dest: &Path, repo_dir: &Path) -> Result<()> {
    let Some(parent) = dest.parent() else {
        return Ok(());
    };
    if !parent.is_symlink() {
        return Ok(());
    }
    let target = fs::read_link(parent)?;
    let abs_target = if target.is_absolute() {
        target
    } else {
        parent
            .parent()
            .unwrap_or(Path::new("."))
            .join(&target)
            .canonicalize()
            .unwrap_or(target)
    };
    if !abs_target.starts_with(repo_dir) {
        return Ok(());
    }
    fs::remove_file(parent)?;
    fs::create_dir_all(parent)?;
    copy_dir_recursive(&abs_target, parent)?;
    Ok(())
}

fn copy_dir_recursive(src: &Path, dst: &Path) -> Result<()> {
    fs::create_dir_all(dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let from = entry.path();
        let to = dst.join(entry.file_name());
        if from.is_dir() {
            copy_dir_recursive(&from, &to)?;
        } else {
            fs::copy(&from, &to)?;
        }
    }
    Ok(())
}

/// Callback de confirmation — permet de mocker dans les tests.
pub type ConfirmFn = dyn Fn(&str) -> bool;

/// Migre un fichier/dir existant vers un symlink. Appelle `confirm` si diff.
pub fn migrate_item(
    item: &Item,
    repo_dir: &Path,
    target: &Path,
    cli: &str,
    confirm: &ConfirmFn,
) -> Result<LinkOutcome> {
    let src = item.src_path(repo_dir, cli);
    let dest = item.dest_path(target, cli);

    if !dest.exists() && !dest.is_symlink() {
        return Ok(LinkOutcome::Linked);
    }
    if is_ours(&dest, repo_dir) {
        return Ok(LinkOutcome::AlreadyOurs);
    }

    let cmp_target = if dest.is_symlink() {
        fs::read_link(&dest).unwrap_or_else(|_| dest.clone())
    } else {
        dest.clone()
    };

    let matches = content_matches(&src, &cmp_target).unwrap_or(false);

    if !matches {
        let msg = format!("Replace {} with repo version?", item.id());
        if !confirm(&msg) {
            return Ok(LinkOutcome::Aborted);
        }
    }

    if dest.is_dir() && !dest.is_symlink() {
        fs::remove_dir_all(&dest).with_context(|| format!("rm -rf {}", dest.display()))?;
    } else {
        fs::remove_file(&dest).with_context(|| format!("rm {}", dest.display()))?;
    }
    if let Some(parent) = dest.parent() {
        fs::create_dir_all(parent)?;
    }
    unix_fs::symlink(&src, &dest)
        .with_context(|| format!("symlink {} -> {}", dest.display(), src.display()))?;
    Ok(LinkOutcome::Migrated)
}

/// Crée symlink pour un item. Auto-migre si fichier existant différent.
pub fn link_item(
    item: &Item,
    repo_dir: &Path,
    target: &Path,
    cli: &str,
    confirm: &ConfirmFn,
) -> Result<LinkOutcome> {
    let src = item.src_path(repo_dir, cli);
    let dest = item.dest_path(target, cli);

    unfold_dir(&dest, repo_dir)?;

    if is_ours(&dest, repo_dir) {
        return Ok(LinkOutcome::AlreadyOurs);
    }

    if dest.exists() || dest.is_symlink() {
        return migrate_item(item, repo_dir, target, cli, confirm);
    }

    if let Some(parent) = dest.parent() {
        fs::create_dir_all(parent)?;
    }
    unix_fs::symlink(&src, &dest)
        .with_context(|| format!("symlink {} -> {}", dest.display(), src.display()))?;
    Ok(LinkOutcome::Linked)
}

/// Retire symlink si c'est le nôtre. Sinon no-op (avec warn via caller).
pub fn unlink_item(item: &Item, repo_dir: &Path, target: &Path, cli: &str) -> Result<bool> {
    let dest = item.dest_path(target, cli);
    if is_ours(&dest, repo_dir) {
        fs::remove_file(&dest)?;
        Ok(true)
    } else {
        Ok(false)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::test_fixtures::Fixture;
    use tempfile::TempDir;

    fn always_yes(_: &str) -> bool { true }
    fn always_no(_: &str) -> bool { false }

    #[test]
    fn is_ours_false_for_missing() {
        let f = Fixture::new();
        assert!(!is_ours(&f.target().join("nope"), f.repo()));
    }

    #[test]
    fn is_ours_false_for_foreign_symlink() {
        let f = Fixture::new();
        let foreign_target = f.repo().join("..").canonicalize().unwrap();
        let link = f.target().join("link");
        unix_fs::symlink(&foreign_target, &link).unwrap();
        assert!(!is_ours(&link, f.repo()));
    }

    #[test]
    fn is_ours_true_for_foreign_catalog_layout() {
        // Simule: install faite via un autre clone (cargo run dans le repo
        // dev) puis détection depuis le binary bundled. Les paths diffèrent
        // mais la structure catalogue est reconnue.
        let f = Fixture::new();
        let target = f.target();
        let other = TempDir::new().unwrap();
        let catalog_file = other.path().join("claude/.claude/commands/x.md");
        fs::create_dir_all(catalog_file.parent().unwrap()).unwrap();
        fs::write(&catalog_file, "x").unwrap();

        let link = target.join(".claude/commands/x.md");
        fs::create_dir_all(link.parent().unwrap()).unwrap();
        unix_fs::symlink(&catalog_file, &link).unwrap();

        // repo_dir ne pointe PAS vers `other`, mais is_ours reconnait la
        // structure catalogue et le fichier existe -> ours.
        assert!(is_ours(&link, f.repo()));
    }

    #[test]
    fn is_ours_true_for_our_symlink() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        link_item(&item, f.repo(), &target, "claude", &always_yes).unwrap();
        let dest = item.dest_path(&target, "claude");
        assert!(is_ours(&dest, f.repo()));
    }

    #[test]
    fn unfold_dir_replaces_parent_symlink_with_real_dir() {
        let f = Fixture::new();
        let target = f.target();
        // parent pointe vers repo (simule install stow-style)
        let parent_dest = target.join(".claude/commands");
        fs::create_dir_all(parent_dest.parent().unwrap()).unwrap();
        let repo_commands = f.repo().join("claude/.claude/commands");
        unix_fs::symlink(&repo_commands, &parent_dest).unwrap();

        let item_dest = parent_dest.join("caveman.md");
        unfold_dir(&item_dest, f.repo()).unwrap();

        assert!(parent_dest.is_dir());
        assert!(!parent_dest.is_symlink());
        // contenu copié
        assert!(parent_dest.join("caveman.md").exists());
    }

    #[test]
    fn unfold_dir_noop_when_parent_not_symlink() {
        let f = Fixture::new();
        let target = f.target();
        let parent = target.join(".claude/commands");
        fs::create_dir_all(&parent).unwrap();
        let item_dest = parent.join("x.md");
        unfold_dir(&item_dest, f.repo()).unwrap();
        assert!(parent.is_dir());
    }

    #[test]
    fn unfold_dir_skips_symlinks_pointing_outside_repo() {
        let f = Fixture::new();
        let target = f.target();
        let outside = TempDir::new().unwrap();
        fs::create_dir_all(outside.path().join("sub")).unwrap();
        let parent = target.join(".claude/commands");
        fs::create_dir_all(parent.parent().unwrap()).unwrap();
        unix_fs::symlink(outside.path(), &parent).unwrap();

        unfold_dir(&parent.join("x.md"), f.repo()).unwrap();
        // Doit rester symlink car hors repo
        assert!(parent.is_symlink());
    }

    #[test]
    fn link_item_creates_symlink() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        let outcome = link_item(&item, f.repo(), &target, "claude", &always_yes).unwrap();
        assert_eq!(outcome, LinkOutcome::Linked);
        let dest = item.dest_path(&target, "claude");
        assert!(dest.is_symlink());
        assert!(is_ours(&dest, f.repo()));
    }

    #[test]
    fn link_item_idempotent_for_ours() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        link_item(&item, f.repo(), &target, "claude", &always_yes).unwrap();
        let outcome = link_item(&item, f.repo(), &target, "claude", &always_no).unwrap();
        assert_eq!(outcome, LinkOutcome::AlreadyOurs);
    }

    #[test]
    fn link_item_migrates_existing_with_confirm() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        let dest = item.dest_path(&target, "claude");
        fs::create_dir_all(dest.parent().unwrap()).unwrap();
        fs::write(&dest, "foreign content").unwrap();

        let outcome = link_item(&item, f.repo(), &target, "claude", &always_yes).unwrap();
        assert_eq!(outcome, LinkOutcome::Migrated);
        assert!(dest.is_symlink());
    }

    #[test]
    fn link_item_aborts_when_user_refuses() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        let dest = item.dest_path(&target, "claude");
        fs::create_dir_all(dest.parent().unwrap()).unwrap();
        fs::write(&dest, "foreign content").unwrap();

        let outcome = link_item(&item, f.repo(), &target, "claude", &always_no).unwrap();
        assert_eq!(outcome, LinkOutcome::Aborted);
        assert!(!dest.is_symlink());
    }

    #[test]
    fn unlink_item_removes_ours() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        link_item(&item, f.repo(), &target, "claude", &always_yes).unwrap();
        let removed = unlink_item(&item, f.repo(), &target, "claude").unwrap();
        assert!(removed);
        assert!(!item.dest_path(&target, "claude").exists());
    }

    #[test]
    fn unlink_item_leaves_foreign_alone() {
        let f = Fixture::new();
        let target = f.target();
        let item = Item { category: "commands".into(), name: "caveman".into() };
        let dest = item.dest_path(&target, "claude");
        fs::create_dir_all(dest.parent().unwrap()).unwrap();
        fs::write(&dest, "foreign").unwrap();

        let removed = unlink_item(&item, f.repo(), &target, "claude").unwrap();
        assert!(!removed);
        assert!(dest.exists());
    }

    #[test]
    fn content_matches_identical_files() {
        let f = Fixture::new();
        let a = f.repo().join("a.txt");
        let b = f.repo().join("b.txt");
        fs::write(&a, "hello").unwrap();
        fs::write(&b, "hello").unwrap();
        assert!(content_matches(&a, &b).unwrap());
    }

    #[test]
    fn content_matches_different_files() {
        let f = Fixture::new();
        let a = f.repo().join("a.txt");
        let b = f.repo().join("b.txt");
        fs::write(&a, "hello").unwrap();
        fs::write(&b, "world").unwrap();
        assert!(!content_matches(&a, &b).unwrap());
    }
}
