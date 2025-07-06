#!/bin/bash
# install-auto-route.sh: Installs the auto-route NetworkManager dispatcher script
set -e

DISPATCHER_PATH="/etc/NetworkManager/dispatcher.d/99-auto-route"
SCRIPT_SRC="$(dirname "$0")/99-auto-route"

if [ ! -f "$SCRIPT_SRC" ]; then
    echo "Error: $SCRIPT_SRC not found. Please place 99-auto-route in $(dirname "$0") before running this script."
    exit 1
fi

sudo cp "$SCRIPT_SRC" "$DISPATCHER_PATH"
sudo chmod +x "$DISPATCHER_PATH"
echo "[INFO] Installed dispatcher script to $DISPATCHER_PATH."

sudo systemctl reload NetworkManager
sudo systemctl restart NetworkManager

echo "[INFO] NetworkManager reloaded. Auto-route logic is now active." 