#!/usr/bin/env bash
# Watches lib/ and fires a hot reload on the running flutter session.
# Talks to flutter only through its --pid-file: SIGUSR1 reloads, SIGUSR2 restarts.
#
# Backends: fswatch (macOS, preferred), inotifywait (Linux), or plain polling.
# Polling needs no extra tools, so auto-reload works on a fresh Mac out of the box.
set -uo pipefail

WATCH_DIR="${WATCH_DIR:-lib}"
PIDFILE="${PIDFILE:-build/flutter.pid}"
LOGFILE="${LOGFILE:-build/hot-reload.log}"
DEBOUNCE="${DEBOUNCE:-0.25}"
RELOAD_SIGNAL="${RELOAD_SIGNAL:-USR1}"
POLL_INTERVAL="${POLL_INTERVAL:-0.6}"

[ -d "$WATCH_DIR" ] || { echo "watch dir not found: $WATCH_DIR" >&2; exit 1; }

mkdir -p "$(dirname "$LOGFILE")" || exit 1
lock="$(dirname "$LOGFILE")/.watch.lock"
held="$(dirname "$LOGFILE")/.watch.held"
rm -rf "$lock" "$held"

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >>"$LOGFILE"; }

# Echo the pid of a live flutter session, or fail. Checking the command line is
# what stops a recycled pid from being signalled when the pid file outlives a crash.
session_pid() {
  local pid cmd
  [ -s "$PIDFILE" ] || return 1
  pid=$(tr -dc '0-9' <"$PIDFILE")
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  if [ -r "/proc/$pid/cmdline" ]; then
    cmd=$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null)
  else
    cmd=$(ps -p "$pid" -o command= 2>/dev/null)
  fi
  case "$cmd" in *flutter*) ;; *) return 1 ;; esac
  printf '%s' "$pid"
}

# Reload now, or hold the change until a session shows up. Dropping it would
# lose a save made during the first build, which is exactly when people save.
fire() {
  local pid
  if pid=$(session_pid); then
    if kill "-$RELOAD_SIGNAL" "$pid" 2>/dev/null; then
      log "hot reload -> pid $pid"
      return 0
    fi
  fi
  : >"$held"
  log "no live flutter session, change held"
}

ticker_pid=""
stamp=""

drain_held() {
  while :; do
    sleep 1
    [ -e "$held" ] || continue
    local pid
    if pid=$(session_pid); then
      if kill "-$RELOAD_SIGNAL" "$pid" 2>/dev/null; then
        rm -f "$held"
        log "hot reload (held change) -> pid $pid"
      fi
    fi
  done
}

stop() {
  [ -n "$ticker_pid" ] && kill "$ticker_pid" 2>/dev/null
  [ -n "$stamp" ] && rm -f "$stamp"
  exit 0
}
trap stop EXIT INT TERM

drain_held &
ticker_pid=$!

# mkdir is atomic, so the first event of a quiet window owns the window and
# everything the editor writes during it collapses into one reload.
debounced_fire() {
  mkdir "$lock" 2>/dev/null || return 0
  sleep "$DEBOUNCE"
  fire
  rmdir "$lock" 2>/dev/null
}

backend="poll"
if command -v fswatch >/dev/null 2>&1; then
  backend="fswatch"
elif command -v inotifywait >/dev/null 2>&1; then
  backend="inotifywait"
fi
log "watcher started: backend=$backend dir=$WATCH_DIR"

case "$backend" in
  fswatch)
    fswatch -0 -r \
      --event Created --event Updated --event Removed --event Renamed \
      "$WATCH_DIR" |
      while IFS= read -r -d '' path; do
        case "$path" in
          *.dart) debounced_fire ;;
        esac
      done
    ;;
  inotifywait)
    inotifywait -m -q -r \
      -e create,modify,delete,move,close_write \
      --format '%e %w%f' \
      "$WATCH_DIR" 2>/dev/null |
      while read -r _ path; do
        case "$path" in
          *.dart) debounced_fire ;;
        esac
      done
    ;;
  poll)
    # macOS has no inotify, and fswatch may not be installed. Polling mtimes is
    # portable and fast enough for a hot-reload loop.
    stamp="$(mktemp "${TMPDIR:-/tmp}/uxapp-watch.XXXXXX")" || exit 1
    touch "$stamp"
    while :; do
      sleep "$POLL_INTERVAL"
      changed=$(find "$WATCH_DIR" -type f -name '*.dart' -newer "$stamp" 2>/dev/null | head -n 1)
      [ -n "$changed" ] || continue
      touch "$stamp"
      debounced_fire
    done
    ;;
esac
