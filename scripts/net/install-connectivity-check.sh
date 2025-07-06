#!/bin/bash
# install-connectivity-check.sh: Configures NetworkManager connectivity check
set -e

NM_CONF="/etc/NetworkManager/NetworkManager.conf"
CONNECTIVITY_SECTION="[connectivity]"
CONNECTIVITY_URI="uri=http://connectivity-check.ubuntu.com"
CONNECTIVITY_INTERVAL="interval=15"

# Add or update the connectivity section
if ! grep -q "^\[connectivity\]" "$NM_CONF"; then
    echo -e "\n$CONNECTIVITY_SECTION\n$CONNECTIVITY_URI\n$CONNECTIVITY_INTERVAL" | sudo tee -a "$NM_CONF" > /dev/null
    echo "[INFO] Added [connectivity] section to $NM_CONF."
else
    # Update or add uri and interval lines
    sudo sed -i "/^\[connectivity\]/,/^\[/ {/^uri=/d;/^interval=/d}" "$NM_CONF"
    sudo sed -i "/^\[connectivity\]/a $CONNECTIVITY_URI\n$CONNECTIVITY_INTERVAL" "$NM_CONF"
    echo "[INFO] Updated [connectivity] section in $NM_CONF."
fi

sudo systemctl reload NetworkManager
sudo systemctl restart NetworkManager

echo "[INFO] NetworkManager connectivity check is enabled (uri: connectivity-check.ubuntu.com, interval: 15s)." 