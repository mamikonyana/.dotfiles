################
# this file is dependent on
# ~/.zsh_aliases for aliases
# ~/.system_colors/.hostcolor for color of the prompt


# Keep the list of aliases in a separate file
# Helps keep this file clean
if [ -f zsh_aliases ]; then
  . ./zsh_aliases
fi


############################################################
# Environment variables
############################################################

export EDITOR=vim

#############################################################
# History 
#############################################################
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.histfile
setopt hist_ignore_dups # ignore same command run 1+ times
setopt appendhistory #don't overwrite history
setopt histignorealldups sharehistory #???

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

#############################################################
# Prompt
#############################################################


## Set up the prompt
autoload -U promptinit
promptinit

setopt promptsubst

HOSTCOLOR=$(grep 'prompt: ' ./colors.config | sed 's/prompt: //')


function parse_git_branch {
  branch=`git symbolic-ref HEAD 2> /dev/null | cut -d'/' -f3`
  
  if [ "$branch" = "" ]; then
    echo "$branch"
  else
    echo " ($branch)"
  fi
}

autoload -U colors && colors

prompt_color1=$HOSTCOLOR
prompt_color2=$HOSTCOLOR


base_prompt="%{$fg_bold[$prompt_color1]%}%n@%m%{$reset_color%}:"
path_prompt="%{$fg[$prompt_color2]%}%(4~|...|)%3~%{$fg[red]%}\$(parse_git_branch)"

PS1="$base_prompt$path_prompt%{$reset_color%}
%{$fg[$prompt_color1]%}%#%{$reset_color%} "

###################################################
# Tab color
# ##################################################

RGB=$(grep 'iterm-rgb: ' ./colors.config | sed 's/iterm-rgb: //')

red_value=`echo $RGB | cut -d\, -f 1`
green_value=`echo $RGB | cut -d\, -f 2`
blue_value=`echo $RGB | cut -d\, -f 3`

echo -e "\x1b]6;1;bg;red;brightness;$red_value\x07\x1b]6;1;bg;green;brightness;$green_value\x07\x1b]6;1;bg;blue;brightness;$blue_value\x07"

################################################################################
# Smart tab titles
################################################################################

function set_tab_title {
    rlength="20"
    tab_label="$PWD:h:t/$PWD:t"
    echo -ne "\e]1;${(l:rlength:)tab_label}\a"
}
set_tab_title
PS2=set_tab_title

bell=`tput bel` 
precmd () { 
  echo -n "\033]2;$PWD >- $USERNAME@$HOST ($status)$bell" 
} 
#PROMPT='%m %B%3c%(#.#.>)%b ' 
RPROMPT=''


#######################################################################################
# rest (found in auto options)
###################################################################################

# Use modern completion system
autoload -Uz compinit
compinit



zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
#eval "$(dircolors -b)" # raises error
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
