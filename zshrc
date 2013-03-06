################
# this file is dependent on
# ~/.zsh_aliases for aliases
# ~/.system_colors/.hostcolor for color of the prompt


# Keep the list of aliases in a separate file
# Helps keep this file clean
if [ -f zsh_aliases ]; then
  . ./zsh_aliases
fi


################################################################################
#  OS type
################################################################################

OS="Linux"
if [ "$HOME" = "/Users/$USER" ]; then
  OS="OSX"
fi

############################################################
# Environment variables
############################################################

export EDITOR=vim

#############################################################
# History 
#############################################################
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE=~/.zsh_history
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
#prompt adam1
#

function hashcolor()
{
  case `echo $@ | md5sum | head -c 1` in
    [01]) echo red     ;;
    [23]) echo green   ;;
    [45]) echo blue    ;;
    [67]) echo grey    ;;
    [89]) echo magenta ;;
    [ab]) echo yellow  ;;
    [cd]) echo black   ;;
    [ef]) echo cyan    ;;
    *)    echo white ;;
  esac
}

if test -e ~/.system_colors/.hostcolor
then
  export HOSTCOLOR=`cat ~/.system_colors/.hostcolor`
elif test -e /etc/hostcolor
then
  export HOSTCOLOR=`cat /etc/hostcolor`
else
  export HOSTCOLOR=$(hashcolor `hostname`)
fi


function extract_open_arc_differentials {
  if [ $OS = "Linux" ]; then
    git log 2> /dev/null --author=arsen -n 30| grep -Pzo "(Author: .* <$USER@locu.com>)(\n.*){3,11}?(\n    Differential Revision: .*|\n    Reviewed By: [a-z]*)" | grep "Differential Revision:" | grep -Po "(http://phabricator.locu.com/D[0-9]{1,})"
  fi
}

function parse_arc_differential {
  out=`extract_open_arc_differentials`
  if [ -n "$out" ]; then
    echo "\n$out"
  fi
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

autoload -U colors && colors

prompt_color1=$HOSTCOLOR
prompt_color2=$HOSTCOLOR


base_prompt="%{$fg_bold[$prompt_color1]%}%n@%m%{$reset_color%}:"
path_prompt="%{$fg[$prompt_color2]%}%(4~|...|)%3~%{$fg[red]%}\$(parse_git_branch)\$(parse_arc_differential)"

PS1="$base_prompt$path_prompt%{$reset_color%}
%{$fg[$prompt_color1]%}%#%{$reset_color%} "

###################################################
# Tab color
# ##################################################

red_value=`cat ~/.system_colors/.rgb | cut -d\, -f 1`
green_value=`cat ~/.system_colors/.rgb | cut -d\, -f 2`
blue_value=`cat ~/.system_colors/.rgb | cut -d\, -f 3`

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

#LASTCMD_START=0
#TITLEHOST=`hostname`
#
#function microtime()    { date +'%s.%N' }
#function set_titlebar() { 
#  [[ "$TERM" = "xterm" ]] && echo -n $'\e]0;'"$@"'\a' 
#  [[ "$TERM" = "cygwin" ]] && echo -n $'\e]0;'"$@"'\a' 
#}
#
## Called before user command
#function preexec(){
#  set_titlebar $TITLEHOST\$ "$1"
#  LASTCMD_START=`microtime` 
#  LASTCMD="$1"
#}
#
## Called after user cmd
#function precmd(){ 
#  if [[ "$LEGACY_ZSH" != "1" ]]
#  then
#    set_titlebar "$TITLEHOST:`echo "$PWD" | sed "s@^$HOME@~@"`"
#    local T=0 ; (( T = `microtime` - $LASTCMD_START ))
#    if (( $LASTCMD_START > 0 )) && (( T>1 ))
#    then
#      T=`echo $T | head -c 10` 
#      LASTCMD=`echo "$LASTCMD" | grep -ioG '^[a-z0-9./_-]*'`
#      echo "$LASTCMD took $T seconds"
#    fi
#    LASTCMD_START=0
#  fi
#}
#
#


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
