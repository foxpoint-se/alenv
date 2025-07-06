#!/bin/bash
# Setup script for Sixfab Modem Watchdog
# Installs, enables, disables, or uninstalls the watchdog service

set -e
SERVICE_NAME="sixfab-watchdog.service"
SCRIPT_PATH="/usr/local/bin/sixfab-watchdog.sh"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
LOGFILE="/var/log/sixfab-watchdog.log"

usage() {
    echo "Usage: $0 [install|uninstall|status|logs]"
    echo "  install   - Install and enable the Sixfab watchdog service"
    echo "  uninstall - Disable and remove the service and script"
    echo "  status    - Show service status"
    echo "  logs      - Tail the watchdog log file"
    exit 1
}

install() {
    echo "Installing Sixfab Watchdog..."
    sudo cp sixfab-watchdog.sh "$SCRIPT_PATH"
    sudo chmod +x "$SCRIPT_PATH"
    # Create systemd service
    sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Sixfab Modem Watchdog
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now "$SERVICE_NAME"
    echo "Sixfab Watchdog installed and started."
}

uninstall() {
    echo "Uninstalling Sixfab Watchdog..."
    sudo systemctl disable --now "$SERVICE_NAME" || true
    sudo rm -f "$SERVICE_PATH"
    sudo rm -f "$SCRIPT_PATH"
    echo "Uninstalled."
}

status() {
    systemctl status "$SERVICE_NAME" --no-pager
}

logs() {
    sudo tail -n 50 -f "$LOGFILE"
}

case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    *)
        usage
        ;;
esac 