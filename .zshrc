# --- Timing Configuration ---
# Set to 'true' to see timestamps, 'false' to hide them
DEBUG_ZSH_TIMING=false

zsh_time() {
  zmodload zsh/datetime
  [[ "$DEBUG_ZSH_TIMING" == "true" ]] && echo "$1,,${EPOCHREALTIME:0:14}"
}

zsh_time "1" # Start

# --- Environment Basics ---
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export KEYTIMEOUT=1
HIST_STAMPS="mm/dd/yyyy"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.histfile
setopt hist_ignore_dups
setopt appendhistory
setopt histignorealldups sharehistory

zsh_time "6" # Basic Env Set

# --- Path & Editor Configuration ---
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export GEM_HOME=/opt/homebrew/lib/ruby/gems/3.3.0
export PATH=$GEM_HOME/bin:$PATH

export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/.local/bin # uv
export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH=/opt/homebrew/share/google-cloud-sdk/bin:"$PATH"
export PATH="/Users/arsen/.antigravity/antigravity/bin:$PATH"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export REACT_EDITOR=code
bindkey -v

zsh_time "72" # Paths & Editors Set

# --- NVM (Lazy Load) ---
# This fixes the 0.6s delay. NVM only loads when you type 'node', 'npm', etc.
export NVM_DIR="$HOME/.nvm"
function nvm node npm yarn pnpm {
  unfunction nvm node npm yarn pnpm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  "$0" "$@"
}

zsh_time "78" # NVM Configured (Instant now)

# --- Pyenv (Auto-fix Lock) ---
# This attempts to remove the stale lock file that caused the 60s hang
if [[ -f "$HOME/.pyenv/shims/.pyenv-shim" ]]; then
    # Check if the lock is older than 1 minute and delete it
    if [[ $(find "$HOME/.pyenv/shims/.pyenv-shim" -mmin +1) ]]; then
        rm -f "$HOME/.pyenv/shims/.pyenv-shim"
    fi
fi

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

zsh_time "86" # Pyenv Init

# --- Secrets & Extras ---
export TF_VAR_LOOPEDIN_DEPLOY_DB2_MASTER_PASS="op://Tech/aws-db-3-master-pass/password"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Browser & Aliases
export BROWSER="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
export CONTAINERS_MACHINE_PROVIDER=applehv
# Changed from export to alias (correct usage for command flags)
alias rsync="rsync -a -v --info=progress2 --info=name0 -chavzP --stats"

zsh_time "99" # Ready for Prompt

# --- Starship Prompt ---
# Initialized last so it can see all the variables (node version, java, etc)
eval "$(starship init zsh)"
