# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
#DEFAULT_USER="$USER"


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
plugins=(git macos zsh-syntax-highlighting zsh-completions zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export DOTFILES=$HOME/dotfiles

# import 
source $DOTFILES/.key.env.sh
source $DOTFILES/bin/functions.sh
source $DOTFILES/bin/alias.sh
source $DOTFILES/function_gpg.sh
function bit() {
  source $DOTFILES/function_bitwarden.sh
}

# PATHs for dotfiles
export PATH=$DOTFILES:$DOTFILES/bin:$PATH
alias dev="$DOTFILES/bin/dev-cyberark.sh"


# jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# rbenv
export PATH={$Home}/.rbenv/bin:$PATH
eval "$(rbenv init -)"

# Python - pyenv
export PATH="$(pyenv root)/shims:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi


# iterm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# java
alias java_home=/usr/libexec/java_home
#"JAVA Version: jenv versions -> jenv global 18"
#export JAVA_HOME=$(java_home -v 1.8)
#alias setJava8='export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)'
#alias setJava17='export JAVA_HOME=$(/usr/libexec/java_home -v 18)'
#export PATH="$PATH:$JAVA_HOME"

# stty - ^M 
#stty icrnl

# nvim - Neo Vim
#alias vim="nvim"
#alias vi="nvim"
#alias vimdiff="nvim -d"
#export EDITOR=/usr/local/bin/nvim
#
export PATH="$PATH:/Users/a1101066/.local/bin" # Added by Docker Gremlin"

# kubectl 
[[ /opt/homebrew/bin/kubectl ]] && source <(kubectl completion zsh)
alias k=kubectl
complete -F __start_kubectl k

# minikube
#source <(minikube completion zsh)

# multi kubernetes context 
#export KUBECONFIG=~/.kube/config:~/.kube/int-k8s-dev-config

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export COLUMNS="120"

export PATH="$PATH:${HOME}/ACLI"

export HOMEBREW_NO_INSTALL_CLEANUP=true
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# CLI - syntax-highlight
LESSPIPE=`which src-hilite-lesspipe.sh`
export LESSOPEN="| ${LESSPIPE} %s"
export LESS=' -R -X -F '
alias less='less -R'
alias more='more -R'
alias ccat='highlight -O ansi --force'
alias lcat=lolcat

eval "$(gh copilot alias -- zsh)"

# ngrok completion
#if command -v ngrok &>/dev/null; then
#  eval "$(ngrok completion)"
#fi

export PATH="$HOME/.deno/bin:$PATH"

alias yy='yoyak summary -l ko '
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
