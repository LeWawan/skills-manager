mod convert;
mod discovery;
mod item;
mod link;
mod ui;

#[cfg(test)]
mod test_fixtures;

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use std::env;
use std::path::PathBuf;

/// Resolve the catalogue root. Priority:
/// 1. `SKILLS_REPO` env var if set (dev override)
/// 2. Directory holding the binary (prebuilt tarball layout)
/// 3. Current working dir (dev `cargo run` from the repo)
fn resolve_repo_dir() -> Result<PathBuf> {
    if let Ok(path) = env::var("SKILLS_REPO") {
        return Ok(PathBuf::from(path));
    }
    let exe = env::current_exe().context("current_exe")?;
    // Resolve symlinks so the binary finds the catalogue even when invoked
    // through a shim in /usr/local/bin -> ~/.local/share/skills-manager/...
    let exe = exe.canonicalize().unwrap_or(exe);
    let exe_dir = exe
        .parent()
        .context("binary has no parent dir")?
        .to_path_buf();
    if exe_dir.join("claude").join(".claude").is_dir()
        || exe_dir.join("opencode").join(".opencode").is_dir()
    {
        return Ok(exe_dir);
    }
    env::current_dir().context("current_dir")
}

#[derive(Parser)]
#[command(name = "skills-manager", version)]
struct Cli {
    #[command(subcommand)]
    command: Option<Command>,
}

#[derive(Subcommand)]
enum Command {
    /// Menu interactif (install/uninstall)
    Run,
    /// Liste items (debug): claude ou opencode
    List { cli: String },
    /// Convertit les commandes Claude en skills OpenCode
    Convert,
}

fn main() -> Result<()> {
    let cli_args = Cli::parse();
    let repo_dir = resolve_repo_dir()?;
    let target: PathBuf = env::var("HOME").context("HOME not set")?.into();

    match cli_args.command.unwrap_or(Command::Run) {
        Command::Run => ui::run(&repo_dir, &target)?,
        Command::List { cli } => {
            let all = discovery::list_all(&repo_dir, &cli)?;
            let visible = discovery::list_visible(&repo_dir, &cli, &all);
            println!("== ALL ({}) ==", all.len());
            for item in &all {
                println!("  {}", item.id());
            }
            println!("== VISIBLE ({}) ==", visible.len());
            for item in &visible {
                let desc = discovery::desc_of(&repo_dir, &cli, item)
                    .map(|d| format!(" — {d}"))
                    .unwrap_or_default();
                println!("  {}{}", item.id(), desc);
            }
        }
        Command::Convert => convert::run(&repo_dir)?,
    }
    Ok(())
}
