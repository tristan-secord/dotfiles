export PATH=/opt/homebrew/bin:$PATH

## Original ZSH Commands
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

source /Users/tristansecord/google-cloud-sdk/path.zsh.inc
source /Users/tristansecord/google-cloud-sdk/completion.zsh.inc

# Github aliases
alias dev="cd ~/Development/"
alias gs="git status"
alias gco="git commit -a -S -m"
alias gc="git checkout"
alias ga="git add"
alias gp="git push"
alias gpr="git pull --rebase"
alias grh="git reset --hard"
alias gr="git fetch && git rebase -i"
alias lg="lazygit"
alias gpf="git push --force-with-lease origin" 

alias gresign="git rebase --exec 'git commit --amend --no-edit -n -S' -i"

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
alias pf="pants run kiid-sync-desktop:fmt && pants run kiid-sync-desktop:lint && pants run kiid-sync-desktop:test"
alias pfl="pants run kiid-sync-desktop:lint"
alias pff="pants run kiid-sync-desktop:fmt"
alias pft="pants run kiid-sync-desktop:test"
alias pfd="pants run kiid-sync-desktop:dev"
alias pb="pants update-build-files tailor fmt fix lint check test ::"
alias pbl="pants lint ::"
alias pbf="pants fmt fix ::"
alias pbt="pants test ::"
alias pbtailor="pants tailor ::"
alias pbc="pants check ::"
alias pbu="pants update-build-files ::"
alias pbexp="pants export-codegen ::"
alias pbgen="pants generate-lockfiles ::"

. /opt/homebrew/opt/asdf/libexec/asdf.sh

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
# DISABLE_UNTRACKED_FILES_DIRTY="true"

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
plugins=(git)

source $ZSH/oh-my-zsh.sh

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
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
. "/Users/tristansecord/.deno/env"
