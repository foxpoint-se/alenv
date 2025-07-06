# Ethernet Setup (Optional)

If you want to use a direct Ethernet connection (e.g., for initial setup or as a backup):

1. **Plug in the Ethernet cable**
   - Most modern Ubuntu images will auto-configure DHCP on `eth0`.

2. **Check status:**
   ```sh
   nmcli device status
   ip a
   ping -I eth0 8.8.8.8
   ```

3. **(Optional) Set a static IP:**
   ```sh
   sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1 ipv4.dns 8.8.8.8 ipv4.method manual
   sudo nmcli connection up "Wired connection 1"
   ```
   - Adjust the connection name and IP details as needed.

---
Return to [README](../README.md)
