#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

source "$HOME/.config/env"
export HISTFILE="$XDG_STATE_HOME/bash/history"

