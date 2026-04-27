# List available recipes
default:
    @just --list

# Run all CI checks locally (fmt + clippy + test)
check:
    cargo fmt --all -- --check
    cargo clippy --all-targets --locked -- -D warnings
    cargo test --release --locked

# Auto-fix formatting and clippy lints
fix:
    cargo fmt --all
    cargo clippy --all-targets --locked --fix --allow-dirty --allow-staged

# Build release binary
build:
    cargo build --release --locked

# Run the binary against a disposable HOME
e2e:
    HOME=/tmp/skills-manager-e2e cargo run --release

# List what the installer sees for each CLI
list:
    cargo run --release -- list claude
    cargo run --release -- list opencode

# Regenerate OpenCode skills from Claude commands
convert:
    cargo run --release -- convert
