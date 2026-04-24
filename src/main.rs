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

#[derive(Parser)]
#[command(name = "skills", version)]
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
    let repo_dir = env::current_dir()?;
    let target: PathBuf = env::var("HOME")
        .context("HOME not set")?
        .into();

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
