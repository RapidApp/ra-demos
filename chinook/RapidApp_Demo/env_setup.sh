#!/bin/bash
#
#  NOTE: EXPECTS TO BE RAN FROM:
#    ra-demos/chinook/RapidApp_Demo
#
# Usage:
#
#   source env_setup.sh
#
# These commands prepare the command environment for the
# demo. It sets a custom/simple prompt and sets up a 
# custom/dedicated history file in basic (no timestamp)
# mode.
#
# UPDATE: also sets up aliases and can be ran any time
# to be able to jump back into the demo in the middle
# with correct history

## tmp for dev:
export PERLLIB=/root/github/RapidApp/lib
export RAPIDAPP_SHARE_DIR=/root/github/RapidApp/share

# quick/dirty find vimrc file in either local, parent or grandparent dir
vimrc_file="$PWD/vimrc"
if [ ! -f $vimrc_file ]; then
  vimrc_file="$PWD/../vimrc"
fi
if [ ! -f $vimrc_file ]; then
  vimrc_file="$PWD/../../vimrc"
fi

# for .vimrc
export VIMINIT="source $vimrc_file"

## ----
## Setup Commit aliases
##
## This is duplicated in part 1, but is also here
## to allow jumping in at a later point:
alias Commit='\
    history -a cmd_history.sh && \
    RestoreHistNewlines cmd_history.sh && \
    git add --all && \
    git commit -m'

alias RestoreHistNewlines='\
  sed -i -e \
   '"'"'/\\$/,/[^\\]$/{p;d;};/^[a-z]/s/ \( \) *\([^#]\)/ \\\n \1 \2/g'"'"''
##
## ----

### setup prompt and history
export PS1='\[\033[01;34m\] \W >\[\033[00m\] '
unset HISTTIMEFORMAT
shopt -s cmdhist lithist
rm -f ~/ra_demo_tmp_history.txt
export HISTFILE=~/ra_demo_tmp_history.txt
history -c && clear
## --
