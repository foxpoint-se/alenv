#!/bin/bash
# Sixfab Modem Watchdog Script
# Checks if wwan0 is up and can reach the internet; restarts Sixfab service if not.

LOGFILE="/var/log/sixfab-watchdog.log"
CHECK_INTERVAL=30  # seconds
SIXFAB_SERVICE="sixfab-qmi.service"  # Change if your service name is different

log() {
    echo "[$(date --iso-8601=seconds)] $*" | tee -a "$LOGFILE"
}

while true; do
    if ip addr show wwan0 | grep -q "inet "; then
        if ping -I wwan0 -c 2 -W 5 8.8.8.8 >/dev/null; then
            log "wwan0 is up and internet is reachable."
        else
            log "wwan0 is up but cannot reach internet. Restarting $SIXFAB_SERVICE."
            systemctl restart "$SIXFAB_SERVICE"
        fi
    else
        log "wwan0 interface not found or no IP. Restarting $SIXFAB_SERVICE."
        systemctl restart "$SIXFAB_SERVICE"
    fi
    sleep "$CHECK_INTERVAL"
done 