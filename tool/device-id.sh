#!/usr/bin/env bash
set -uo pipefail

id="$(xcrun devicectl list devices 2>/dev/null |
  grep -Ei '(iphone|ipad)' |
  grep -Eiv '(unavailable|disconnected)' |
  grep -Ei '(connected|available)' |
  grep -oE '[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}' |
  head -n 1)"

if [ -n "$id" ]; then
  printf '%s\n' "$id"
  exit 0
fi

dir="$(mktemp -d "${TMPDIR:-/tmp}/devicectl.XXXXXX")" || exit 1
trap 'rm -rf "$dir"' EXIT
json="$dir/devices.json"

if xcrun devicectl --json-output "$json" list devices >/dev/null 2>&1 && [ -s "$json" ]; then
  jq -r '
    [.result.devices[]?
     | select((.hardwareProperties.deviceType // .hardwareProperties.platform // "")
              | test("^(iPhone|iPad|iOS)$"))
     | select((.connectionProperties.pairingState // "paired") == "paired")]
    | .[0].identifier // empty' "$json" 2>/dev/null
fi
