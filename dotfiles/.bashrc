#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color|*-256color) color_prompt=yes;;
esac

PROMPT_DIRTRIM=2
if [ "$color_prompt" = yes ]; then
  PS1="\[\033[01;30m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
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
  alias ls='ls --color=always'
  #alias dir='dir --color=always'
  #alias vdir='vdir --color=always'

  alias grep='grep --color=always'
  alias fgrep='fgrep --color=always'
  alias egrep='egrep --color=always'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ${HOME}/.bash_aliases ]; then
  . "${HOME}/.bash_aliases"
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

set -o vi
#export TERM="xterm-256color"
#[ -n "$PS1" ] && sh ~/.vim/bundle/snow/shell/snow_dark.sh
alias tmux='tmux -2'
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

export_with_directory() {
  local var_name=$1  # Variable name
  local dir_name=$2  # Directory name

  # Check if the variable is already set and not null
  if [ -n "${!var_name}" ]; then
    # If the variable is set and not null, append the directory to it
    export "$var_name=$dir_name${!var_name:+:${!var_name}}"
  else
    # If the variable is not set or null, set it to the directory
    export "$var_name=$dir_name"
  fi
}
# Is AUX_HOME defined?
if [ -z "${AUX_HOME}" ]; then
  export AUX_HOME=/workspace
fi
export VISUAL=vim
export EDITOR="$VISUAL"
export_with_directory PATH "/usr/local/bin"
export_with_directory PATH "${HOME}/.local/bin"
export_with_directory LD_LIBRARY_PATH "${HOME}/.local/lib"

ros2_on(){
  export ROS_DOMAIN_ID=42
  export ROS_VERSION=2
  export ROS_PYTHON_VERSION=3
  export ROS_DISTRO=humble
  source /opt/ros/humble/venv/bin/activate
  source /opt/ros/humble/setup.bash
  # export ROS_LOCALHOST_ONLY=1
}
ros_on(){
  export ROS_DOMAIN_ID=42
  export ROS_VERSION=1
  export ROS_PYTHON_VERSION=3
  export ROS_DISTRO=noetic
  source /opt/ros/noetic/venv/bin/activate
  source /opt/ros/noetic/setup.bash
}

export npm_config_prefix="$HOME/.local"

complete -cf sudo # autocomplete sudo commands

venv_on() {
  source "${AUX_HOME}/opt/venv/bin/activate"
}

export CoverageControl_ws="${AUX_HOME}/CoverageControl_ws" # Change this to your workspace directory
export_with_directory PATH "${CoverageControl_ws}/install/bin"
export_with_directory LD_LIBRARY_PATH "${CoverageControl_ws}/install/lib"
export CoverageControlCore_DIR="${CoverageControl_ws}/install/CoverageControl/"
export GeographicLib_DIR="${CoverageControl_ws}/install/CoverageControl/lib/cmake/GeographicLib/"

export Flocking_ws="${AUX_HOME}/Documents/repo/flocking"

export Torch_DIR=${AUX_HOME}/opt/libtorch/
venv_cc() {
  source "${CoverageControl_ws}/venv/bin/activate"
}

export CUDA_HOME=/opt/cuda
export CUDA_PATH=/opt/cuda
export_with_directory PATH /opt/cuda/bin
export_with_directory LD_LIBRARY_PATH /usr/local/lib
export_with_directory LD_LIBRARY_PATH /opt/cuda/lib64
source /opt/venv/bin/activate
export NVCC_CCBIN=gcc-13
