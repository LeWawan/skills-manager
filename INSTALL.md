# Installation

Prebuilt binaries are published on every code release. The [GitLab Releases page](https://gitlab.com/delupay/tooling/skills-manager/-/releases) lists the assets for:

- **macOS** — Apple Silicon (`aarch64`) and Intel (`x86_64`)
- **Linux** — `x86_64` (glibc) and `aarch64` (glibc)

Each release's description includes a ready-to-run install snippet for every platform — the sections below mirror that, in case you land on this file first.

If your platform is not listed, [build from source](#build-from-source).

---

## Table of contents

- [Prebuilt binaries](#prebuilt-binaries)
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

## Prebuilt binaries

Every asset is served from the project's Generic Package Registry. Replace `<TAG>` with the release you want, e.g. `v1.0.0`.

> **Tip**: the simplest path is to open the [Releases page](https://gitlab.com/delupay/tooling/skills-manager/-/releases), pick a release, and copy the curl snippet already rendered in its description.

### macOS (Apple Silicon)

- Download `skills-manager-macos-aarch64.tar.gz`
- Clear quarantine: `xattr -c ./skills-manager-macos-aarch64.tar.gz`
- Extract: `tar xzvf skills-manager-macos-aarch64.tar.gz`
- Run: `./skills-manager`

```bash
curl -LO "https://gitlab.com/api/v4/projects/delupay%2Ftooling%2Fskills-manager/packages/generic/skills-manager/<TAG>/skills-manager-macos-aarch64.tar.gz"
xattr -c ./skills-manager-macos-aarch64.tar.gz
tar xzvf skills-manager-macos-aarch64.tar.gz
./skills-manager
```

### macOS (Intel)

- Download `skills-manager-macos-x86_64.tar.gz`
- Clear quarantine: `xattr -c ./skills-manager-macos-x86_64.tar.gz`
- Extract: `tar xzvf skills-manager-macos-x86_64.tar.gz`
- Run: `./skills-manager`

```bash
curl -LO "https://gitlab.com/api/v4/projects/delupay%2Ftooling%2Fskills-manager/packages/generic/skills-manager/<TAG>/skills-manager-macos-x86_64.tar.gz"
xattr -c ./skills-manager-macos-x86_64.tar.gz
tar xzvf skills-manager-macos-x86_64.tar.gz
./skills-manager
```

### Linux (x86_64)

- Download `skills-manager-linux-x86_64.tar.gz`
- Extract: `tar xzvf skills-manager-linux-x86_64.tar.gz`
- Run: `chmod +x ./skills-manager && ./skills-manager`

```bash
curl -LO "https://gitlab.com/api/v4/projects/delupay%2Ftooling%2Fskills-manager/packages/generic/skills-manager/<TAG>/skills-manager-linux-x86_64.tar.gz"
tar xzvf skills-manager-linux-x86_64.tar.gz
chmod +x ./skills-manager
./skills-manager
```

### Linux (aarch64)

- Download `skills-manager-linux-aarch64.tar.gz`
- Extract: `tar xzvf skills-manager-linux-aarch64.tar.gz`
- Run: `chmod +x ./skills-manager && ./skills-manager`

```bash
curl -LO "https://gitlab.com/api/v4/projects/delupay%2Ftooling%2Fskills-manager/packages/generic/skills-manager/<TAG>/skills-manager-linux-aarch64.tar.gz"
tar xzvf skills-manager-linux-aarch64.tar.gz
chmod +x ./skills-manager
./skills-manager
```

---

## Verifying checksums

Each tarball ships with a `.sha256` sidecar attached to the same Release. Download both and verify:

```bash
curl -LO "https://gitlab.com/api/v4/projects/delupay%2Ftooling%2Fskills-manager/packages/generic/skills-manager/<TAG>/skills-manager-macos-aarch64.tar.gz"
curl -LO "https://gitlab.com/api/v4/projects/delupay%2Ftooling%2Fskills-manager/packages/generic/skills-manager/<TAG>/skills-manager-macos-aarch64.tar.gz.sha256"
shasum -a 256 -c skills-manager-macos-aarch64.tar.gz.sha256
```

A successful check prints `skills-manager-macos-aarch64.tar.gz: OK`.

---

## Putting the binary on your PATH

Once the binary runs, move it somewhere on your `PATH`:

```bash
sudo install -m 755 ./skills-manager /usr/local/bin/skills-manager
# or, without sudo:
mkdir -p ~/.local/bin && install -m 755 ./skills-manager ~/.local/bin/skills-manager
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
git clone https://gitlab.com/delupay/tooling/skills-manager.git
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

Need more context? See the [repository layout in STRUCTURE.md](STRUCTURE.md) or file an issue on the [GitLab project](https://gitlab.com/delupay/tooling/skills-manager).
