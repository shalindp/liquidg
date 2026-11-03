#!/usr/bin/env bash
# make flutter: runs the app in the foreground and reloads it on lib/ changes.
# Ctrl-C stops both. flutter owns the terminal; the watcher only writes the log.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

build=build
pidfile="$build/flutter.pid"
logfile="$build/hot-reload.log"

mkdir -p "$build" || exit 1
: >"$logfile"

install_hint() {
  if command -v brew >/dev/null 2>&1; then echo "brew install fswatch"
  elif command -v pacman >/dev/null 2>&1; then echo "sudo pacman -S inotify-tools"
  elif command -v apt-get >/dev/null 2>&1; then echo "sudo apt-get install -y inotify-tools"
  elif command -v dnf >/dev/null 2>&1; then echo "sudo dnf install inotify-tools"
  else echo "install fswatch (macOS) or inotify-tools (Linux)"
  fi
}

if ! command -v fswatch >/dev/null 2>&1 && ! command -v inotifywait >/dev/null 2>&1; then
  echo "fswatch not installed — auto-reload is using 600ms polling for now."
  echo "  for instant reloads: $(install_hint)"
  echo "  watcher log: $logfile"
fi

watcher_pid=""
cleanup() {
  [ -n "$watcher_pid" ] || return 0
  kill "$watcher_pid" 2>/dev/null
  wait "$watcher_pid" 2>/dev/null
  watcher_pid=""
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT TERM

PIDFILE="$pidfile" LOGFILE="$logfile" ./tool/watcher.sh >>"$logfile" 2>&1 &
watcher_pid=$!

flutter run --pid-file="$pidfile" --dart-define-from-file=env.json