#!/bin/bash
# Idempotent setup for SSM agent to wait for wwan0 before starting
set -e

SCRIPT_SRC="$(dirname "$0")/wait-for-wwan.sh"
SCRIPT_DST="/usr/local/bin/wait-for-wwan.sh"
SYSTEMD_OVERRIDE_DIR="/etc/systemd/system/amazon-ssm-agent.service.d"
SYSTEMD_OVERRIDE_FILE="$SYSTEMD_OVERRIDE_DIR/wait-for-wwan.conf"

# 1. Install the script if needed
if ! cmp -s "$SCRIPT_SRC" "$SCRIPT_DST"; then
  echo "Copying wait-for-wwan.sh to $SCRIPT_DST..."
  sudo cp "$SCRIPT_SRC" "$SCRIPT_DST"
  sudo chmod +x "$SCRIPT_DST"
else
  echo "wait-for-wwan.sh is already up to date in $SCRIPT_DST."
fi

# 2. Create systemd override directory if needed
if [ ! -d "$SYSTEMD_OVERRIDE_DIR" ]; then
  echo "Creating systemd override directory $SYSTEMD_OVERRIDE_DIR..."
  sudo mkdir -p "$SYSTEMD_OVERRIDE_DIR"
fi

# 3. Write override file (idempotent)
cat <<EOF | sudo tee "$SYSTEMD_OVERRIDE_FILE" > /dev/null
[Unit]
After=network-online.target
Wants=network-online.target

[Service]
ExecStartPre=$SCRIPT_DST
EOF

echo "Systemd override written to $SYSTEMD_OVERRIDE_FILE."

# 4. Reload systemd and restart SSM agent
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
echo "Restarting amazon-ssm-agent service..."
sudo systemctl restart amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

echo "Done!"
echo

echo "You can check logs (including wait-for-wwan.sh output) with:"
echo "  sudo journalctl -u amazon-ssm-agent -b" 