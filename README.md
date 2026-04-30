# Dotfiles (~/.config)

My macOS dotfiles managed via git in `~/.config/`. Uses a **Catppuccin Mocha** theme across Ghostty, tmux, and Neovim.

## Quick Start (New Machine)

```sh
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Clone dotfiles
git clone <repo-url> ~/.config

# 3. Install dependencies
brew bundle --file=~/.config/Brewfile

# 4. Bootstrap shell
cat <<'EOF' > ~/.zshenv
export ZDOTDIR="$HOME/.config/zsh"
export EDITOR=nvim
. "$HOME/.cargo/env"
EOF

ln -sf ~/.config/zsh/.zshrc ~/.zshrc
ln -sf ~/.config/zsh/.zprofile ~/.zprofile

# 5. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 6. Install tmux plugins (TPM)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# Then open tmux and press: prefix + I (C-t + I)

# 7. Open Neovim — lazy.nvim and Mason auto-install on first launch
nvim
```

## What's Included

| Directory   | What                                   |
|-------------|----------------------------------------|
| `zsh/`      | `.zshrc`, `.zprofile`, history, completions |
| `nvim/`     | Neovim config (Lua, lazy.nvim)         |
| `tmux/`     | tmux config + TPM plugin list          |
| `ghostty/`  | Ghostty terminal config                |
| `k9s/`      | k9s config + Dracula skin              |
| `opencode/` | OpenCode AI assistant config           |
| `nats/`     | NATS messaging config                  |

## Shell Setup

Zsh is redirected to `~/.config/zsh/` via `ZDOTDIR` in `~/.zshenv`. The symlinks at `~/.zshrc` and `~/.zprofile` point back into the repo for compatibility with tools that expect them in `$HOME`.

**`~/.zshenv`** is the only file that lives outside the repo — it must be created manually (see Quick Start step 4).

## Brewfile

Run `brew bundle --file=~/.config/Brewfile` to install all dependencies. To update the Brewfile after installing new packages:

```sh
brew bundle dump --file=~/.config/Brewfile --force
```

## Tmux

- Prefix is **C-t** (not the default C-b)
- Plugins are managed by TPM and gitignored — install with `prefix + I` after cloning TPM
- `C-o` opens an OpenCode popup

## Neovim

- lazy.nvim auto-bootstraps on first launch
- Mason auto-installs LSP servers (lua_ls, elixirls, pyright, rust_analyzer)
- External formatters needed: `stylua`, `prettier`, `black`, `isort`, `rubocop` (included in Brewfile)
- `node_host_prog` expects Node via asdf at `~/.asdf/shims/node`

## Additional Setup

Some tools require setup beyond `brew bundle`:

- **Rust** — `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Oh My Zsh** — see Quick Start step 5
- **Google Cloud SDK** — install to `~/google-cloud-sdk/` per [docs](https://cloud.google.com/sdk/docs/install)
- **OrbStack** — install from [orbstack.dev](https://orbstack.dev), it creates `~/.orbstack/shell/init.zsh`
- **Nerd Fonts** — Ghostty config uses `Berkeley Mono Nerd Font`
- **GPG** — set up for commit signing (`GPG_TTY` is configured in .zshrc)
- **k9s** — macOS reads from `~/Library/Application Support/k9s/` rather than `~/.config/k9s/`; symlink it: `ln -s ~/.config/k9s ~/Library/Application\ Support/k9s`

## Production Safety

kube-ps1 is configured to turn the terminal background **red** when the kubectl context matches `*prod*` — a visual guard against accidental production commands.
