#!/bin/bash
# Optional: switch between the green and white Matrix themes by Tailscale state.
# Connected -> enter-the-matrix, disconnected -> enter-the-matrix-white.
#
#   extras/tailscale/install.sh             install and start the user service
#   extras/tailscale/install.sh --remove    stop it and take it back

set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN="$HOME/.local/bin/matrix-tailscale-theme"
UNIT="$HOME/.config/systemd/user/matrix-tailscale-theme.service"

if [[ ${1:-} == "--remove" ]]; then
  systemctl --user disable --now matrix-tailscale-theme.service 2>/dev/null || true
  rm -f "$BIN" "$UNIT"
  systemctl --user daemon-reload
  echo "removed the Tailscale theme switch"
  exit 0
fi

command -v tailscale >/dev/null || { echo "tailscale is not installed" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is not installed" >&2; exit 1; }

mkdir -p "$(dirname "$BIN")" "$(dirname "$UNIT")"
ln -sfn "$HERE/matrix-tailscale-theme" "$BIN"
install -m 644 "$HERE/matrix-tailscale-theme.service" "$UNIT"
systemctl --user daemon-reload
systemctl --user enable matrix-tailscale-theme.service >/dev/null
systemctl --user restart matrix-tailscale-theme.service
echo "the theme now follows Tailscale: green when connected, white when not"
