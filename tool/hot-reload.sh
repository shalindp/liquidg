#!/usr/bin/env bash
set -euo pipefail

session="${1:-dev}"
pidfile="/tmp/hot-reload.${session}.pid"

if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
  echo "watcher already running (pid $(cat "$pidfile"))"
  exit 0
fi
echo $$ >"$pidfile"

stamp=$(mktemp)
trap 'rm -f "$stamp" "$pidfile"' EXIT

while :; do
  if find lib -type f -name '*.dart' -newer "$stamp" -print -quit | grep -q .; then
    touch "$stamp"
    sleep 0.3
    if ! tmux has-session -t "$session" 2>/dev/null; then
      echo "tmux session '${session}' gone, watcher exiting"
      exit 0
    fi
    tmux send-keys -t "$session" r Enter
    echo "[$(date +%T)] lib/ changed -> hot reload"
  fi
  sleep 1
done
