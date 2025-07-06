#!/bin/bash

# This script uses multitail to tail all relevant logs for SSM debugging.
# Each log is prefixed with a label for clarity.
# Install multitail if not already installed: sudo apt install multitail

multitail \
  -l "sudo journalctl -u amazon-ssm-agent -f | sed 's/^/[SSM-Agent] /'" \
  -l "sudo journalctl -u ssm-watchdog -f | sed 's/^/[SSM-Watchdog] /'" \
  -l "sudo journalctl -u NetworkManager -f | sed 's/^/[NetworkManager] /'" \
  -l "sudo journalctl -u ModemManager -f | sed 's/^/[ModemManager] /'" \
  -l "sudo journalctl -u systemd-timesyncd -f | sed 's/^/[TimeSync] /'" \
  -l "sudo journalctl -f | sed 's/^/[Syslog] /'" 