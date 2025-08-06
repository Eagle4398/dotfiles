#####################################################
## The below is debian bookworm autocreation

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth

shopt -s histappend

HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
 . "$HOME/.cargo/env"

## The above is debian bookworm autocreation
#####################################################

if [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]]; then
    tmux
fi

# Below follows massive logic for adding of paths and environment variables from 
# a file basically it is necessary in order to have flexible $HOME or $BASHRC
# related paths or other variables like SSH_AUTH_SOCK.
# The only reason I did this is to keep NixOS compatibility

prepend_path() {
  local dir_to_add="$1"
  local expanded_dir

  if ! expanded_dir=$(eval echo "$dir_to_add"); then
      echo "Warning: Could not expand path '$dir_to_add'" >&2
      return 1
  fi


  if [[ -n "$expanded_dir" && -d "$expanded_dir" ]]; then
    case ":$PATH:" in
      *":${expanded_dir}:"*)
        ;;
      *)
        PATH="${expanded_dir}:$PATH"
        ;;
    esac
  fi
}
export -f prepend_path

bashrc_realpath=""
if command -v realpath >/dev/null 2>&1; then
  bashrc_realpath=$(realpath "${BASH_SOURCE[0]}")
else
  SOURCE="${BASH_SOURCE[0]}"
  while [[ -h "$SOURCE" ]]; do 
    DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  done
   bashrc_realpath="$SOURCE"
fi

bashrc_dir=$(dirname "$bashrc_realpath")

# custom paths all in one file 
paths_file="${bashrc_dir}/stowignore/path.txt" 

if [[ -f "$paths_file" ]]; then
  while IFS= read -r path_line || [[ -n "$path_line" ]]; do 
    [[ -z "$path_line" || "$path_line" =~ ^\s*# ]] && continue
    prepend_path "$path_line" # prepends each line of file to path
  done < "$paths_file"
  export PATH
else
  echo "Warning: Path definition file '$paths_file' not found." >&2
fi

unset -f prepend_path

# Environment variables from file
exports_file="${bashrc_dir}/stowignore/exports.txt" 

if [[ -f "$exports_file" ]]; then
  while IFS= read -r export_line || [[ -n "$export_line" ]]; do 
    trimmed_line=$(echo "$export_line" | sed -e 's/^[[:space:]]*//') 
    [[ -z "$trimmed_line" || "$trimmed_line" =~ ^# ]] && continue
    eval "$export_line" # this executes lines of "export BLA=bla"
  done < "$exports_file"
else
  echo "Warning: Exports definition file '$exports_file' not found." >&2

fi

export DOTFILES="${bashrc_dir}" 
# # These are imported through the exports_file
# export PY_PATH="/home/gloo/builds/python_glob_env"
# export VISUAL=nvim
# export EDITOR=nvim
# export SUDO_EDITOR=nvim
# export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# pyenv has precedence of course (if installed, otherwise this fails silently)
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

