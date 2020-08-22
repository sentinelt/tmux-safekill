#!/usr/bin/env bash
set -e

function safe_end_procs {
  old_ifs="$IFS"
  IFS=$'\n'
  for pane_set in $1; do
    pane_id=$(echo "$pane_set" | awk -F " " '{print $1}')
    pane_proc=$(echo "$pane_set" | awk -F " " '{print tolower($2)}')
    pane_pid=$(echo "$pane_set" | awk -F " " '{print tolower($3)}')
    if [[ "$pane_proc" == "vim" ]] || [[ "$pane_proc" == "nvim" ]]; then
		echo "Escape :xa" | xargs tmux send-keys -t "$pane_id"
		sleep 1
    fi
	kill "$pane_pid"
  done
  IFS="$old_ifs"
}

function safe_kill_panes_of_current_session {
  session_name=$(tmux display-message -p '#S')
  current_panes=$(tmux list-panes -a -F "#{pane_id} #{pane_current_command} #{pane_pid} #{session_name}\n" | grep "$session_name")

  SAVEIFS="$IFS"
  IFS=$'\n'
  array=($current_panes)
  # Restore IFS
  IFS=$SAVEIFS
  for (( i=0; i<${#array[@]}; i++ ))
  do
    safe_end_procs "${array[$i]}"
  done
}

safe_kill_panes_of_current_session
exit 0
