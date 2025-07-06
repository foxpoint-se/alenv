#!/bin/bash
# uninstall-auto-route.sh: Removes the auto-route NetworkManager dispatcher script
set -e

DISPATCHER_PATH="/etc/NetworkManager/dispatcher.d/99-auto-route"

if [ -f "$DISPATCHER_PATH" ]; then
    sudo rm "$DISPATCHER_PATH"
    echo "[INFO] Removed dispatcher script from $DISPATCHER_PATH."
else
    echo "[INFO] Dispatcher script not found at $DISPATCHER_PATH. Nothing to remove."
fi

sudo systemctl reload NetworkManager
sudo systemctl restart NetworkManager

echo "[INFO] NetworkManager reloaded. Auto-route logic is now uninstalled." 