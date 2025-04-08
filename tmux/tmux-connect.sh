#!/bin/bash
set -x
# Simple script that will create a new tmux session and connect to nodes in our
# special cluster.
# Input would be a file with a list of machine names that you can get with a command like below.
# kubectl --insecure-skip-tls-verify get nodes -o custom-columns=:.metadata.name -l testnode

randval=${RANDOM}
pane_count=0
window=0
: ${user:="root"}
: ${option_key:=""}
#if [ -n "`tmux ls | grep nodes-all-${randval}`" ]; then
#  echo; echo -n "Session with that name exists. Kill it? [y|n]: "
#  read RES
#  if [[ $RES == +(y|Y) ]]; then
#    tmux kill-session -t nodes-all-${randval}
#  else
#    exit 0
#  fi
#fi
tmux -2 new-session -d -s nodes-all-${randval}
for machine in "$@"; do
  tmux split-window
  pane_count=$((pane_count+1))
  tmux send-keys -t ${window}.${pane_count} "stty -echo" Enter \; send-keys -t ${window}.${pane_count} "ssh -o StrictHostKeyChecking=no -t ${machine}" Enter \; send-keys -t ${window}.${pane_count} "stty echo" Enter
  tmux select-layout tiled
  if [ $pane_count -eq 51 ]; then
    window=$((window+1))
    pane_count=1
    tmux new-window -t ${window}
  fi
done
echo

