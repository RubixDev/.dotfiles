#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

source "$HOME/.config/env"
export HISTFILE="$XDG_STATE_HOME/bash/history"

shopt -s extglob failglob
source "$HOME/.config/aliasrc"

# autojump
[[ -s /usr/share/autojump/autojump.bash ]] && source /usr/share/autojump/autojump.bash
