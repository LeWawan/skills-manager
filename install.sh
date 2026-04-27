#!/usr/bin/env sh
# -----------------------------------------------------------------------------
# skills-manager installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/LeWawan/skills-manager/main/install.sh | sh
#
# Environment overrides:
#   SKILLS_MANAGER_VERSION  release tag to pin (e.g. v1.2.3). default: latest
#   SKILLS_MANAGER_DIR      install root. default: $HOME/.local/share/skills-manager
#   SKILLS_MANAGER_BIN      symlink dir.   default: $HOME/.local/bin
#   GITHUB_TOKEN            GitHub PAT (only needed to bypass anonymous rate limit)
# -----------------------------------------------------------------------------
set -eu

REPO="LeWawan/skills-manager"
API_BASE="https://api.github.com"
DOWNLOAD_BASE="https://github.com/${REPO}/releases/download"
INSTALL_DIR="${SKILLS_MANAGER_DIR:-$HOME/.local/share/skills-manager}"
BIN_DIR="${SKILLS_MANAGER_BIN:-$HOME/.local/bin}"

AUTH_HEADER=""
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_HEADER="Authorization: Bearer $GITHUB_TOKEN"
fi

# --- detect OS / arch ---------------------------------------------------------
case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *) echo "error: unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  arm64|aarch64)  ARCH=aarch64 ;;
  x86_64|amd64)   ARCH=x86_64 ;;
  *) echo "error: unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac
PLATFORM="${OS}-${ARCH}"

# --- resolve version ----------------------------------------------------------
VERSION="${SKILLS_MANAGER_VERSION:-}"
if [ -z "$VERSION" ]; then
  echo "==> Fetching latest release tag..."
  if [ -n "$AUTH_HEADER" ]; then
    LATEST=$(curl -fsSL -H "$AUTH_HEADER" "$API_BASE/repos/$REPO/releases/latest")
  else
    LATEST=$(curl -fsSL "$API_BASE/repos/$REPO/releases/latest")
  fi
  VERSION=$(printf '%s' "$LATEST" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -n1)
fi
if [ -z "$VERSION" ]; then
  echo "error: could not resolve release tag" >&2
  exit 1
fi

TARBALL="skills-manager-${PLATFORM}.tar.gz"
URL="${DOWNLOAD_BASE}/${VERSION}/${TARBALL}"

echo "==> Installing skills-manager ${VERSION} (${PLATFORM})"
echo "    from: $URL"
echo "    to:   $INSTALL_DIR"

# --- download + extract -------------------------------------------------------
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t skills-manager)
trap 'rm -rf "$TMP"' EXIT

if [ -n "$AUTH_HEADER" ]; then
  curl -fsSL -H "$AUTH_HEADER" "$URL" -o "$TMP/${TARBALL}"
else
  curl -fsSL "$URL" -o "$TMP/${TARBALL}"
fi

if [ "$OS" = "macos" ]; then
  xattr -c "$TMP/${TARBALL}" 2>/dev/null || true
fi

tar -C "$TMP" -xzf "$TMP/${TARBALL}"

# --- install ------------------------------------------------------------------
mkdir -p "$(dirname "$INSTALL_DIR")" "$BIN_DIR"
rm -rf "$INSTALL_DIR"
mv "$TMP/skills-manager-${PLATFORM}" "$INSTALL_DIR"

ln -sf "$INSTALL_DIR/skills-manager" "$BIN_DIR/skills-manager"

echo ""
echo "✓ skills-manager ${VERSION} installed"
echo "  catalog:  $INSTALL_DIR"
echo "  command:  $BIN_DIR/skills-manager"
echo ""
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "Note: $BIN_DIR is not on your PATH. Add this to your shell rc:"
    echo "  export PATH=\"$BIN_DIR:\$PATH\""
    echo ""
    ;;
esac
echo "Run: skills-manager"
