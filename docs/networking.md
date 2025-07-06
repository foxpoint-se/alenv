[⬅ Back to main README](../README.md)

# Networking & Wi-Fi

## Adding more Wi-Fi access points

1. Install NetworkManager: `sudo apt install network-manager`
1. Enable and start NetworkManager: `sudo systemctl enable NetworkManager && sudo systemctl start NetworkManager`
1. **Migrate from systemd-networkd to NetworkManager:**
   1. Edit Netplan config: `sudo nano /etc/netplan/50-cloud-init.yaml`
   1. Add renderer line at the top: `renderer: NetworkManager`
   1. Apply changes: `sudo netplan apply`
   1. **Add your current WiFi as a NetworkManager profile:**
      1. Get current WiFi details: `sudo iw dev wlan0 link`
      1. Create profile: `sudo nmcli connection add type wifi con-name "CurrentWiFi" ifname wlan0 ssid "YOUR_CURRENT_SSID"`
      1. Set password: `sudo nmcli connection modify "CurrentWiFi" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "YOUR_CURRENT_PASSWORD"`
   1. **Reboot the Pi and wait 2-3 minutes for NetworkManager to take over**
   1. **Disable systemd-networkd to prevent future conflicts:**
      1. Disable systemd-networkd: `sudo systemctl stop systemd-networkd && sudo systemctl disable systemd-networkd`
1. **Add additional WiFi networks (choose one method):**
   - **Direct connection** (requires network to be in range): `sudo nmcli device wifi connect "SSID" password "password"`
   - **Connection profile** (recommended - works even if network is not present):
     1. Create profile: `sudo nmcli connection add type wifi con-name "MyWiFi" ifname wlan0 ssid "SSID"`
     1. Set password: `sudo nmcli connection modify "MyWiFi" wifi-sec.key-mgmt wpa-psk wifi-sec.psk "password"`
     1. Activate: `sudo nmcli connection up "MyWiFi"`

**Useful commands:**

- List connections: `sudo nmcli connection show`
- Delete connection: `sudo nmcli connection delete "ConnectionName"`
- Check WiFi status: `sudo nmcli device wifi list`
- Monitor connections: `sudo nmcli device status`
- Verify NetworkManager is managing: `sudo systemctl status NetworkManager`

**Troubleshooting (requires physical connection, like ethernet):**

- If you lose connection during migration, reboot and wait 2-3 minutes
- If NetworkManager isn't working, temporarily re-enable systemd-networkd: `sudo systemctl enable systemd-networkd && sudo systemctl start systemd-networkd && sudo netplan apply`
- Check service status: `sudo systemctl status NetworkManager systemd-networkd`

## Automatic Failover Between Wi-Fi and Cellular (wwan0) with NetworkManager

If your device has both Wi-Fi (wlan0) and cellular (wwan0) interfaces, you can automate failover so that all traffic uses cellular only when Wi-Fi is down or has no internet. This is handled by a NetworkManager dispatcher script and does not require you to know connection names.

### How it Works
- The script checks if Wi-Fi is up and has internet (by pinging a reliable host).
- If Wi-Fi is working, it ensures cellular is not used as the default route.
- If Wi-Fi is down or has no internet, it enables the default route on cellular.
- If Wi-Fi connectivity is restored, it switches back to Wi-Fi as default.
- The script is interface-based (wlan0/wwan0), not connection-name-based.

### Installation
1. Place the scripts in `scripts/net/`:
    - `99-auto-route` (the dispatcher script)
    - `install-auto-route.sh` (installer)
    - `uninstall-auto-route.sh` (uninstaller)
2. Run the installer:
    ```sh
    cd scripts/net
    sudo ./install-auto-route.sh
    ```
    This will copy the dispatcher script to `/etc/NetworkManager/dispatcher.d/`, make it executable, and reload NetworkManager.

### Uninstallation
To remove the logic and restore default behavior:
```sh
cd scripts/net
sudo ./uninstall-auto-route.sh
```

### NetworkManager Connectivity Check (Separate Script)
To enable or update NetworkManager's connectivity check (which helps detect if a connection has real internet access), use the separate script:

```sh
cd scripts/net
sudo ./install-connectivity-check.sh
```
- This will add or update the `[connectivity]` section in `/etc/NetworkManager/NetworkManager.conf` with recommended defaults (`uri=http://connectivity-check.ubuntu.com`, `interval=15`).
- **There is no uninstall script for this step.** If you want to remove or change the connectivity check, edit `/etc/NetworkManager/NetworkManager.conf` manually.

### Behavior: Switching Back to Wi-Fi
- By default, the script will switch back to Wi-Fi as soon as it detects Wi-Fi is up and has internet.
- If you want to **avoid switching back automatically** (e.g., stay on cellular until a reboot or manual intervention), you can modify the script logic to only switch to cellular, not back to Wi-Fi.

### Customization
- If your interface names are not `wlan0` and `wwan0`, edit those variables at the top of the dispatcher script.
- You can change the host used for connectivity checks (default: 8.8.8.8) in the script.

### Troubleshooting
- Check logs with `journalctl -u NetworkManager -f` or `sudo tail -f /var/log/syslog`.
- Make sure both interfaces are managed by NetworkManager.
- The script is compatible with any connection names and is robust to interface renaming.
