# Installation

Prebuilt binaries are published on every release. The [GitHub Releases page](https://github.com/LeWawan/skills-manager/releases) lists the assets for:

- **macOS** — Apple Silicon (`aarch64`) and Intel (`x86_64`)
- **Linux** — `x86_64` (glibc) and `aarch64` (glibc)

Each tarball bundles the binary **plus** the `claude/` and `opencode/` catalogues, so the installer works anywhere without cloning the repo.

If your platform is not listed, [build from source](#build-from-source).

---

## Table of contents

- [One-liner install](#one-liner-install)
- [Manual install](#manual-install)
  - [macOS (Apple Silicon)](#macos-apple-silicon)
  - [macOS (Intel)](#macos-intel)
  - [Linux (x86_64)](#linux-x86_64)
  - [Linux (aarch64)](#linux-aarch64)
- [Verifying checksums](#verifying-checksums)
- [Putting the binary on your PATH](#putting-the-binary-on-your-path)
- [Build from source](#build-from-source)
- [Updating](#updating)
- [Uninstalling](#uninstalling)
- [Troubleshooting](#troubleshooting)

---

## One-liner install

```bash
curl -fsSL https://raw.githubusercontent.com/LeWawan/skills-manager/main/install.sh | sh
```

Detects OS + arch, pulls the matching tarball from the latest release, installs to `~/.local/share/skills-manager`, and symlinks the binary into `~/.local/bin/skills-manager`.

**Environment overrides:**

| Variable | Default | Purpose |
|---|---|---|
| `SKILLS_MANAGER_VERSION` | *latest* | Pin to a specific tag, e.g. `v1.2.3` |
| `SKILLS_MANAGER_DIR` | `~/.local/share/skills-manager` | Install root |
| `SKILLS_MANAGER_BIN` | `~/.local/bin` | Symlink location |
| `GITHUB_TOKEN` | — | GitHub PAT (only needed to bypass anonymous rate limit) |

Inspect the script before piping:

```bash
curl -fsSL https://raw.githubusercontent.com/LeWawan/skills-manager/main/install.sh | less
```

---

## Manual install

Every asset is attached to the GitHub Release. Replace `<TAG>` with the release you want, e.g. `v1.0.0`.

> **Tip**: open the [Releases page](https://github.com/LeWawan/skills-manager/releases), pick a release, and copy the asset URL.

### macOS (Apple Silicon)

```bash
curl -LO "https://github.com/LeWawan/skills-manager/releases/download/<TAG>/skills-manager-macos-aarch64.tar.gz"
xattr -c ./skills-manager-macos-aarch64.tar.gz
tar xzvf skills-manager-macos-aarch64.tar.gz
./skills-manager-macos-aarch64/skills-manager
```

### macOS (Intel)

```bash
curl -LO "https://github.com/LeWawan/skills-manager/releases/download/<TAG>/skills-manager-macos-x86_64.tar.gz"
xattr -c ./skills-manager-macos-x86_64.tar.gz
tar xzvf skills-manager-macos-x86_64.tar.gz
./skills-manager-macos-x86_64/skills-manager
```

### Linux (x86_64)

```bash
curl -LO "https://github.com/LeWawan/skills-manager/releases/download/<TAG>/skills-manager-linux-x86_64.tar.gz"
tar xzvf skills-manager-linux-x86_64.tar.gz
./skills-manager-linux-x86_64/skills-manager
```

### Linux (aarch64)

```bash
curl -LO "https://github.com/LeWawan/skills-manager/releases/download/<TAG>/skills-manager-linux-aarch64.tar.gz"
tar xzvf skills-manager-linux-aarch64.tar.gz
./skills-manager-linux-aarch64/skills-manager
```

---

## Verifying checksums

Each tarball ships with a `.sha256` sidecar attached to the same Release. Download both and verify:

```bash
curl -LO "https://github.com/LeWawan/skills-manager/releases/download/<TAG>/skills-manager-macos-aarch64.tar.gz"
curl -LO "https://github.com/LeWawan/skills-manager/releases/download/<TAG>/skills-manager-macos-aarch64.tar.gz.sha256"
shasum -a 256 -c skills-manager-macos-aarch64.tar.gz.sha256
```

A successful check prints `skills-manager-macos-aarch64.tar.gz: OK`.

---

## Putting the binary on your PATH

The binary locates its catalogue relative to its own file (following symlinks), so you can move the bundle to a standard location and symlink the binary:

```bash
# Replace <platform> with macos-aarch64 / macos-x86_64 / linux-x86_64 / linux-aarch64
mv skills-manager-<platform> ~/.local/share/skills-manager
mkdir -p ~/.local/bin
ln -sf ~/.local/share/skills-manager/skills-manager ~/.local/bin/skills-manager
```

Then invoke it from anywhere: `skills-manager`.

---

## Build from source

### Requirements

- [Rust toolchain](https://rustup.rs) stable — Rust 1.79 or newer
- `git`

No other runtime dependency. The TUI is provided by the `inquire` crate.

### Build

```bash
git clone https://github.com/LeWawan/skills-manager.git
cd skills-manager
cargo build --release
./target/release/skills-manager
```

### Install into your `PATH`

```bash
cargo install --path .
skills-manager        # installed to ~/.cargo/bin/skills-manager
```

### Run without installing

```bash
cargo run --release
```

### Run the tests

```bash
cargo test
```

---

## Updating

**Prebuilt binary:** download the newer release and overwrite the old binary.

**From source:**

```bash
git pull
cargo install --path . --force
```

After updating, **re-run `skills-manager`** so the interactive menu can pick up any new agents, commands, or skills added to the catalogue.

---

## Uninstalling

Uninstall the symlinks first, then the binary:

```bash
skills-manager       # choose "Uninstall"
rm "$(command -v skills-manager)"
```

`skills-manager` only removes symlinks that point into this repo — foreign files are left alone.

---

## Troubleshooting

**macOS: "skills-manager cannot be opened because the developer cannot be verified"**

```bash
xattr -c ./skills-manager
```

If you already extracted the tarball, you can also clear it directly on the binary:

```bash
xattr -d com.apple.quarantine skills-manager
```

**Linux: `error while loading shared libraries: libc.so.6`**

The Linux tarballs are built against glibc. On Alpine or other musl-based distros, build from source.

**`Skip — already exists (not ours)` during install**

There is a file at the target path that is not a symlink managed by this repo. Remove or rename it, then re-run `skills-manager`.

**Skills not appearing in OpenCode after install**

- Verify the symlinks exist: `ls -la ~/.opencode/skills/`
- Check that each `SKILL.md` has a valid YAML frontmatter
- Restart OpenCode

**Install aborted mid-way**

When `skills-manager` detects an existing foreign file that differs from the repo version, it asks for confirmation. Declining aborts the whole run. Re-run and confirm, or remove the file manually.

---

Need more context? See the [repository layout in STRUCTURE.md](STRUCTURE.md) or file an issue on the [GitHub project](https://github.com/LeWawan/skills-manager).
