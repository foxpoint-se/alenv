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
