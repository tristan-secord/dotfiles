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
# them, which trips git's dubious-ownership check on every command below —
# not just the first clone.
git config --global --add safe.directory "$CONFIG_REPO"

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

# Make sure ~/.local/bin (fd) is on PATH for future shells.
path_line='export PATH="$HOME/.local/bin:$PATH"'
grep -qxF "$path_line" "$HOME/.bashrc" 2>/dev/null || echo "$path_line" >> "$HOME/.bashrc"
