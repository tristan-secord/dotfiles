#!/usr/bin/env bash
set -euo pipefail

# Don't rely on however this script gets invoked (workspace-utils, a login
# shell, a bare ssh command, ...) to already have a sane PATH — dropbear
# sessions especially strip it down to /usr/bin:/bin. Guarantee it here.
export PATH="/usr/local/bin:/usr/local/sbin:/mnt/personal/bin:$HOME/.local/bin:$PATH"

DOT=/mnt/personal/dotfiles

mkdir -p ~/.config ~/.claude /mnt/personal/bin

# Personal bin
if ! grep -q '/mnt/personal/bin' ~/.bashrc 2>/dev/null; then
  cat >> ~/.bashrc <<'EOF'

# Personal devspaces setup
export PATH="/mnt/personal/bin:$PATH"
EOF
fi

# Helpful aliases
mkdir -p ~/.bashrc.d
cat > ~/.bashrc.d/90-tristan-devspaces.sh <<'EOF'
alias gs='git status'
EOF

echo "Tristan devspaces dotfiles installed"

# --- nvim: config + plugins from the dotfiles repo ----------------------

CONFIG_REPO="$DOT/config"       # your actual dotfiles git repo
DATA_DIR="$DOT/nvim-data"       # installed plugins, NOT git-managed

# /mnt/personal shows files as owned by `nobody` regardless of who wrote
# them, which trips git's dubious-ownership check on every git command
# under it — not just the dotfiles clone, but every individual plugin
# lazy.nvim installs under nvim-data too (each is its own repo). This is
# single-user, personal storage, so the ownership check isn't guarding a
# real trust boundary here — blanket-exempt it rather than list every path.
git config --global --add safe.directory "*"

if [ -d "$CONFIG_REPO/.git" ]; then
  git -C "$CONFIG_REPO" pull --ff-only
else
  # Sparse + cone mode: only nvim/ and devspaces/ get checked out, not
  # every other tool's config that happens to live in the same repo.
  gh repo clone tristan-secord/dotfiles "$CONFIG_REPO" -- --no-checkout
  git -C "$CONFIG_REPO" sparse-checkout init --cone
  git -C "$CONFIG_REPO" sparse-checkout set nvim devspaces
  git -C "$CONFIG_REPO" checkout
fi

# Symlink $HOME/<rel> to a persistent path, migrating any pre-existing
# real directory in on the very first run.
link_persistent_dir() {
  local rel="$1"                 # e.g. ".local/share/nvim"
  local home_path="$HOME/$rel"
  local store_path="$DATA_DIR/$rel"

  mkdir -p "$(dirname "$store_path")"

  if [ -L "$home_path" ]; then
    [ "$(readlink "$home_path")" = "$store_path" ] && return 0
    rm -f "$home_path"
  elif [ -e "$home_path" ]; then
    if [ -e "$store_path" ]; then
      rm -rf "$home_path"        # persistent copy already wins
    else
      mv "$home_path" "$store_path"
    fi
  fi

  mkdir -p "$store_path" "$(dirname "$home_path")"
  ln -sfn "$store_path" "$home_path"
}

# nvim config comes straight from the cloned repo — it's git-managed, so
# just point $HOME at it. Any pre-existing real dir (e.g. the image's
# default config) is replaced, not merged: the repo is the source of truth.
if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  rm -rf "$HOME/.config/nvim"
fi
ln -sfn "$CONFIG_REPO/nvim" "$HOME/.config/nvim"

# Installed plugins / Mason LSP servers / Treesitter parsers. First
# workspace ever: your plugin manager bootstraps fresh here (one-time
# cost). Every workspace after that reuses this same persisted copy.
link_persistent_dir ".local/share/nvim"

# --- CLI tools your nvim plugins shell out to ---------------------------

# node/npm/fd already ship in the image at /usr/local/bin — only fzf and
# ctags are genuinely missing. Not listing node/npm here on purpose: apt's
# versions are older and installing them pulls in ~370 transitive packages
# for nothing.
declare -A APT_PKG_FOR_BIN=(
  [fd]=fd-find
  [fzf]=fzf
  [ctags]=universal-ctags
)
missing_pkgs=()
for bin in "${!APT_PKG_FOR_BIN[@]}"; do
  command -v "$bin" >/dev/null 2>&1 || missing_pkgs+=("${APT_PKG_FOR_BIN[$bin]}")
done
if [ "${#missing_pkgs[@]}" -gt 0 ]; then
  sudo apt-get update -qq
  sudo apt-get install -y "${missing_pkgs[@]}"
fi

mkdir -p "$HOME/.local/bin"

# The image ships nvim 0.9.5 at /usr/bin/nvim — too old for a lazy-lock.json
# pinned against a current nvim (0.10+ Lua/LSP APIs). Fetch a real one from
# GitHub releases, matching your local version, and persist the extracted
# tree in /mnt/personal so it's a one-time download, not per workspace.
# /usr/bin is the lowest-precedence PATH entry here, so a symlink in
# /mnt/personal/bin correctly wins over it without touching /usr/bin/nvim.
NVIM_VERSION="v0.12.4"
NVIM_DIR="$DOT/nvim-bin/$NVIM_VERSION"
if [ ! -x "$NVIM_DIR/bin/nvim" ]; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64) nvim_arch="x86_64" ;;
    aarch64) nvim_arch="arm64" ;;
    *) echo "nvim: unrecognized arch '$arch', skipping upgrade" >&2; nvim_arch="" ;;
  esac
  if [ -n "$nvim_arch" ]; then
    curl -Lo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${nvim_arch}.tar.gz"
    mkdir -p "$NVIM_DIR"
    tar -xzf /tmp/nvim.tar.gz -C "$NVIM_DIR" --strip-components=1
    rm -f /tmp/nvim.tar.gz
  fi
fi
[ -x "$NVIM_DIR/bin/nvim" ] && ln -sf "$NVIM_DIR/bin/nvim" /mnt/personal/bin/nvim

# Debian/Ubuntu ships fd-find's binary as `fdfind`; plugins expect `fd`.
if ! command -v fd >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# lazygit isn't packaged in apt at all. Its binary is a plain portable
# executable, so it goes in the *persistent* /mnt/personal/bin — downloaded
# once, ever, not per workspace. Check that exact path rather than
# `command -v`, so a stray leftover copy elsewhere on PATH can't mask it.
if [ ! -x /mnt/personal/bin/lazygit ]; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64) lg_arch="x86_64" ;;
    aarch64) lg_arch="arm64" ;;
    *) echo "lazygit: unrecognized arch '$arch', skipping" >&2; lg_arch="" ;;
  esac
  if [ -n "$lg_arch" ]; then
    lg_version=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${lg_version}/lazygit_${lg_version}_Linux_${lg_arch}.tar.gz"
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    install /tmp/lazygit /mnt/personal/bin/lazygit
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
  fi
fi

# nvim-treesitter (main branch) shells out to a `tree-sitter` CLI binary to
# compile parsers — not packaged in apt, not the same thing as the
# nvim-treesitter *plugin*. Persistent binary, same pattern as lazygit.
if [ ! -x /mnt/personal/bin/tree-sitter ]; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64) ts_arch="x64" ;;
    aarch64) ts_arch="arm64" ;;
    *) echo "tree-sitter: unrecognized arch '$arch', skipping" >&2; ts_arch="" ;;
  esac
  if [ -n "$ts_arch" ]; then
    curl -Lo /tmp/tree-sitter.gz \
      "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${ts_arch}.gz"
    gunzip -f /tmp/tree-sitter.gz
    install /tmp/tree-sitter /mnt/personal/bin/tree-sitter
    rm -f /tmp/tree-sitter
  fi
fi

# Make sure ~/.local/bin (fd) is on PATH for future shells.
path_line='export PATH="$HOME/.local/bin:$PATH"'
grep -qxF "$path_line" "$HOME/.bashrc" 2>/dev/null || echo "$path_line" >> "$HOME/.bashrc"
