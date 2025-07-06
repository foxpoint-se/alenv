[⬅ Back to main README](../README.md)

# Networking & Failover

## Wi-Fi Setup

1. **Add your Wi-Fi network:**
   ```sh
   sudo nmcli device wifi connect "SSID" password "password"
   ```
   - Replace `SSID` and `password` with your Wi-Fi details.

2. **List and manage connections:**
   ```sh
   sudo nmcli connection show
   sudo nmcli device status
   ```

## Cellular Modem Setup (ModemManager)

1. **Insert your SIM card and connect the modem.**
2. **Create a GSM connection:**
   ```sh
   sudo nmcli connection add type gsm ifname wwan0 con-name "cellular" apn "YOUR_APN"
   sudo nmcli connection up "cellular"
   ```
   - Replace `YOUR_APN` with your SIM's APN.
   - To autoconnect on boot:
     ```sh
     sudo nmcli connection modify "cellular" connection.autoconnect yes
     ```
3. **Check status:**
   ```sh
   nmcli device status
   ifconfig wwan0
   ping -I wwan0 8.8.8.8
   ```

## Automatic Failover: Wi-Fi & Cellular

This repo provides a NetworkManager dispatcher script for automatic, interface-based failover between Wi-Fi and cellular.

### How it Works
- If Wi-Fi (`wlan0`) is up and has internet, it is used as the default route.
- If Wi-Fi is down or has no internet, the default route switches to cellular (`wwan0`).
- When Wi-Fi connectivity is restored, routing switches back automatically.

### Installation
1. Install the dispatcher and helper scripts:
   ```sh
   cd scripts/net
   sudo ./install-auto-route.sh
   ```
2. (Optional) Enable NetworkManager's connectivity check:
   ```sh
   sudo ./install-connectivity-check.sh
   ```

### Uninstallation
To remove the auto-route logic:
```sh
cd scripts/net
sudo ./uninstall-auto-route.sh
```

### Customization & Troubleshooting
- Edit interface names in the dispatcher script if needed.
- Check logs with `journalctl -u NetworkManager -f`.
- Both interfaces must be managed by NetworkManager.

---
Continue with [AWS Session Manager](aws-session-manager.md)
