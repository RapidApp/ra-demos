#!/bin/bash
#
# Usage:
#
#   source env_setup.sh
#
# These commands prepare the command environment for the
# demo. It sets a custom/simple prompt and sets up a 
# custom/dedicated history file in basic (no timestamp)
# mode.

### Clear any previous work
rm -rf RA-ChinookDemo/

## tmp for dev:
export PERLLIB=/root/github/RapidApp/lib
export RAPIDAPP_SHARE_DIR=/root/github/RapidApp/share

### setup prompt and history
export PS1='\[\033[01;34m\] \W >\[\033[00m\] '
unset HISTTIMEFORMAT
shopt -s cmdhist lithist
rm -f ~/cmd_history.sh
export HISTFILE=~/cmd_history.sh
history -c && clear