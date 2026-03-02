export PATH=/opt/homebrew/bin:$PATH

## JAVA
if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 17)
  export PATH="$JAVA_HOME/bin:$PATH"
fi

## ANDROID
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

## OPENAI
[ -f ~/.config/openai.env ] && source ~/.config/openai.env

## NVM (Homebrew) — fast
export NVM_DIR="$HOME/.nvm"
NVM_HOMEBREW="/opt/homebrew/opt/nvm"

load_nvm() {
  unset -f node npm npx pnpm yarn load_nvm
  [ -s "$NVM_HOMEBREW/nvm.sh" ] && . "$NVM_HOMEBREW/nvm.sh"
}

node() { load_nvm; node "$@"; }
npm()  { load_nvm; npm "$@"; }
npx()  { load_nvm; npx "$@"; }
pnpm() { load_nvm; pnpm "$@"; }
yarn() { load_nvm; yarn "$@"; }

## DIRENV
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

## GITHUB ALIAS
alias gresign="git rebase --exec 'git commit --amend --no-edit -n -S' -i"
alias lg="lazygit"

## Docker Alias
alias dprune='docker image prune -a -f --filter "until=168h" && docker builder prune -a -f'

# Tmux Aliases
alias tn="tmux new"
alias tns="tmux new-session -A -s"
alias ta="tmux attach"
alias tas="tmux attach -t"
alias td="tmux kill-session -t"
alias tls="tmux list-sessions"

# Random Aliases
alias uuidcp="python -c 'import uuid; print(str(uuid.uuid4()), end=\"\")' | pbcopy"

## KIID
# Pants Aliases
alias pc='pants --changed-since=origin/main --changed-dependents=transitive'
alias pgen="pants export-codegen generate-lockfiles ::"
# Pants backend
alias pcall="pc update-build-files tailor fix fmt lint check test"
# Pants Helpers
alias pantsdkill="ps aux | awk '/pantsd \[/ { print $2 }' | xargs kill"
# Frontend Aliases
alias frontall="cd ~/Development/kiid && bin/nx lint web --max-warnings=0 && bin/nx format web --fix && bin/nx test web && bin/nx lint core --max-warnings=0 && bin/nx format core --fix && bin/nx test core && bin/nx format mobile --fix && bin/nx lint mobile --max-warnings=0 && bin/nx test mobile && bin/nx typecheck mobile"

# ASDF
[[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && . "/opt/homebrew/opt/asdf/libexec/asdf.sh"

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git kube-ps1)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# --- Kube prompt for Ghostty + tmux ---
_osc_bg() { printf '\033]11;%s\007' "$1"; }        # OSC 11 set background
_osc_bg_reset() { printf '\033]111\007'; }         # OSC 111 reset

setopt promptsubst

k_set_bg_precmd() {
  if [[ "$KUBE_PS1_CONTEXT" == *prod* ]]; then
    _osc_bg "#550000"
  else
    _osc_bg_reset
  fi
}
typeset -ga precmd_functions
(( ${precmd_functions[(I)k_set_bg_precmd]} )) || precmd_functions+=(k_set_bg_precmd)

# Set prompt directly with %~ (full path) instead of %c (last component only)
if [ -f "/opt/homebrew/share/kube-ps1.sh" ] || [ -f "/usr/local/opt/kube-ps1/share/kube-ps1.sh" ]; then
  source "/opt/homebrew/share/kube-ps1.sh" 2>/dev/null || \
  source "/usr/local/opt/kube-ps1/share/kube-ps1.sh" 2>/dev/null
  PROMPT='$(kube_ps1)%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'
  kubeon
else
  PROMPT='%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'
fi

[[ -t 1 ]] && export GPG_TTY=$(tty)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"
