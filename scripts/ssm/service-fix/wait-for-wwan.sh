#!/bin/bash
# Wait until wwan0 is up and can ping 8.8.8.8
# This script is used by systemd to ensure SSM agent only starts when modem is ready

set -e

MAX_WAIT=120  # seconds
WAITED=0

echo "$(date): Waiting for wwan0 interface to be UP..."

# Wait for wwan0 interface to be UP
while ! ip link show wwan0 | grep -q "UP"; do
  sleep 2
  WAITED=$((WAITED+2))
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo "$(date): Timeout waiting for wwan0 to be UP after ${MAX_WAIT}s"
    exit 1
  fi
done

echo "$(date): wwan0 is UP, waiting for internet connectivity..."

# Reset wait counter for ping test
WAITED=0

# Wait for wwan0 to be able to ping 8.8.8.8
while ! ping -I wwan0 -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; do
  sleep 2
  WAITED=$((WAITED+2))
  if [ $WAITED -ge $MAX_WAIT ]; then
    echo "$(date): Timeout waiting for wwan0 to ping 8.8.8.8 after ${MAX_WAIT}s"
    exit 1
  fi
done

echo "$(date): wwan0 has internet connectivity, SSM agent can start"
exit 0 