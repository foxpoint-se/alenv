#!/bin/bash
set -e

# Check for sudo/root
if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] This script must be run as root. Please use sudo." >&2
  exit 1
fi

# Check for APN argument
if [[ -z "$1" ]]; then
  echo "[ERROR] No APN provided. Usage: sudo ./install_sixfab_qmi_service.sh <APN>" >&2
  exit 1
fi
APN="$1"

# 1. Install required packages
echo "[INFO] Installing required packages..."
apt update && apt install -y libqmi-utils udhcpc

echo "[INFO] Packages installed."

# 2. Create the QMI connection script
QMI_SCRIPT="/usr/local/bin/sixfab_qmi_connect.sh"
echo "[INFO] Creating QMI connection script at $QMI_SCRIPT..."
cat > $QMI_SCRIPT <<'EOF'
#!/bin/bash
set -e

LOG=/var/log/sixfab_qmi_connect.log
exec > >(tee -a $LOG) 2>&1

echo "[QMI] --- Starting QMI connection at $(date) ---"

# Check for APN argument
if [[ -z "$1" ]]; then
  echo "[QMI] ERROR: APN argument not provided. Exiting."
  exit 1
fi
APN="$1"
echo "[QMI] Using APN: $APN"

# Wait for modem device to appear
for i in {1..10}; do
    if [ -e /dev/cdc-wdm0 ]; then
        echo "[QMI] Found /dev/cdc-wdm0"
        break
    fi
    echo "[QMI] Waiting for /dev/cdc-wdm0... ($i)"
    sleep 2
done
if [ ! -e /dev/cdc-wdm0 ]; then
    echo "[QMI] ERROR: /dev/cdc-wdm0 not found. Exiting."
    exit 1
fi

# Show modem operating mode
echo "[QMI] Checking modem operating mode:"
qmicli -d /dev/cdc-wdm0 --dms-get-operating-mode || true

# Set modem online (ignore error if already online)
echo "[QMI] Setting modem online:"
qmicli -d /dev/cdc-wdm0 --dms-set-operating-mode='online' || true

# Wait for wwan0 to appear
for i in {1..10}; do
    if ip link show wwan0 > /dev/null 2>&1; then
        echo "[QMI] Found wwan0 interface"
        break
    fi
    echo "[QMI] Waiting for wwan0 interface... ($i)"
    sleep 2
done
if ! ip link show wwan0 > /dev/null 2>&1; then
    echo "[QMI] ERROR: wwan0 interface not found. Exiting."
    exit 1
fi

# Set raw IP mode
echo "[QMI] Setting raw IP mode:"
ip link set wwan0 down || true
echo 'Y' | tee /sys/class/net/wwan0/qmi/raw_ip
ip link set wwan0 up

# Start QMI network with provided APN
echo "[QMI] Starting QMI network with APN: $APN"
qmicli -p -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='$APN',ip-type=4" --client-no-release-cid

# Get IP address via udhcpc
echo "[QMI] Requesting IP address via udhcpc..."
udhcpc -q -f -i wwan0

# Show interface status
echo "[QMI] ifconfig wwan0:"
ifconfig wwan0

echo "[QMI] Pinging sixfab.com via wwan0:"
ping -I wwan0 -c 5 sixfab.com || true

echo "[QMI] --- QMI connection script completed at $(date) ---"
EOF

chmod +x $QMI_SCRIPT

echo "[INFO] QMI connection script created."

# 3. Create systemd service
SERVICE_FILE="/etc/systemd/system/sixfab-qmi.service"
echo "[INFO] Creating systemd service at $SERVICE_FILE..."
cat > $SERVICE_FILE <<EOF
[Unit]
Description=Sixfab QMI Auto Connection Service
After=network.target

[Service]
Type=oneshot
ExecStart=$QMI_SCRIPT $APN
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "[INFO] Reloading systemd and enabling service..."
systemctl daemon-reload
systemctl enable sixfab-qmi.service
systemctl start sixfab-qmi.service

# 4. Show status and logs
echo "[INFO] Service installed at $SERVICE_FILE"
echo "[INFO] Systemd status for sixfab-qmi.service:"
systemctl status sixfab-qmi.service --no-pager

echo "[INFO] ifconfig output:"
ifconfig wwan0 || echo "[INFO] wwan0 not found."

echo "[INFO] Last 20 lines of QMI log:"
tail -n 20 /var/log/sixfab_qmi_connect.log

echo "[INFO] Script complete. If wwan0 is up and ping works, your connection is ready!" 