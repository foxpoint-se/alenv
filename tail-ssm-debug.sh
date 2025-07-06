#!/bin/bash

SESSION="ssm-debug"

# Start new tmux session
tmux new-session -d -s $SESSION

# Pane 1: SSM Agent
tmux send-keys -t $SESSION "echo '== SSM Agent Logs ==' && sudo journalctl -u amazon-ssm-agent -f" C-m

# Pane 2: SSM Watchdog (if exists)
tmux split-window -h -t $SESSION
tmux send-keys -t $SESSION:0.1 "echo '== SSM Watchdog Logs ==' && (sudo journalctl -u ssm-watchdog -f || echo 'No ssm-watchdog service')" C-m

# Pane 3: Sixfab Watchdog (if exists)
tmux split-window -v -t $SESSION:0.1
tmux send-keys -t $SESSION:0.2 "echo '== Sixfab Watchdog Logs ==' && (sudo journalctl -u sixfab-watchdog -f || echo 'No sixfab-watchdog service')" C-m

# Pane 4: NetworkManager
tmux split-window -v -t $SESSION:0.0
tmux send-keys -t $SESSION:0.3 "echo '== NetworkManager Logs ==' && sudo journalctl -u NetworkManager -f" C-m

# Pane 5: ModemManager
tmux split-window -h -t $SESSION:0.3
tmux send-keys -t $SESSION:0.4 "echo '== ModemManager Logs ==' && sudo journalctl -u ModemManager -f" C-m

# Pane 6: System clock sync
tmux split-window -v -t $SESSION:0.4
tmux send-keys -t $SESSION:0.5 "echo '== Time Sync Logs ==' && (sudo journalctl -u systemd-timesyncd -f || sudo journalctl -u ntp -f)" C-m

# Pane 7: General system log
tmux split-window -v -t $SESSION:0.2
tmux send-keys -t $SESSION:0.6 "echo '== General System Logs ==' && sudo journalctl -f" C-m

# Select the first pane
tmux select-pane -t $SESSION:0.0

# Attach to the session
tmux attach-session -t $SESSION 