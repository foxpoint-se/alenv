# How to set up an RPI from scratch

## Installing

Assuming you're on Ubuntu Desktop.

1. Install rpi-imager: `sudo apt install rpi-imager`.
1. Run rpi-imager: `rpi-imager`.
1. Select the inserted SD card.
1. Select OS: Ubuntu Server 22.04 64-bit (for running ROS2 Humble).
1. Click the cog wheel:
1. Set hostname to something suitable.
1. Enable SSH.
1. Add your SSH public key.
1. Configure Wi-Fi:
1. Wi-Fi country SE.
1. Wi-Fi SSID and password.
1. Locale settings.
1. Insert the SD card into the RPi, boot it, and wait for a couple of minutes.
1. You should now be able to SSH into the RPi:
1. Check your Wi-Fi to see if you can see a new device, and get its IP address.
1. `ssh ubuntu@192.168.XX.XXX`.

## More setup

Assuming you have managed to SSH into the RPi.

### Custom banner

1. Google for "ascii text generator".
1. Create some ASCII text and copy that.
1. On the RPi, run `sudo nano /etc/motd`
1. Paste your ASCII text.
1. Save and close.
1. Close SSH connection and log in again to see if it shows up.

### Upgrade system

1. `sudo apt update`
1. `sudo apt upgrade`

### Install ROS2 Humble

Follow this guide: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html

### Adding more Wi-Fi access points

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

### Setting up SSH agent forwarding and Git and AWS user forwarding

1. **On your local machine, edit SSH config:**

   ```bash
   nano ~/.ssh/config
   ```

   Add entry for your Pi:

   ```
   Host rpi
       HostName 192.168.XX.XXX  # Your Pi's IP
       User ubuntu
       ForwardAgent yes
       SetEnv GIT_AUTHOR_NAME="Your Name"
       SetEnv GIT_AUTHOR_EMAIL="your.email@example.com"
       SetEnv GIT_COMMITTER_NAME="Your Name"
       SetEnv GIT_COMMITTER_EMAIL="your.email@example.com"
       SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
   ```

1. **On the Raspberry Pi, configure SSH server:**

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

   Add this line:

   ```
   AcceptEnv GIT_*
   AcceptEnv AWS_*
   ```

1. **Restart SSH service on Pi:**

   ```bash
   sudo systemctl restart ssh
   ```

1. **Test the setup:**

   ```bash
   # On your local machine
   ssh-add -l

   # SSH to Pi and test
   ssh rpi
   ssh-add -l  # Should show your forwarded keys
   echo $GIT_AUTHOR_NAME  # Should show your name
   echo $GIT_AUTHOR_EMAIL  # Should show your email
   ```

1. **Use AWS credentials**

If you're using `aws-vault`, you'll have AWS environment variables active. So make sure to have an AWS vault profile active when SSH:ing into the RPi, if you need to access AWS from there.
