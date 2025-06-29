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

## Setting up Sixfab modem (EG25-G/Quectel)

To set up your Sixfab modem (such as the EG25-G Base HAT) on your Raspberry Pi running Ubuntu 22.04 or similar, follow these steps:

### 1. Use the install script

Run the following command, replacing `<APN>` with your SIM card's APN (for example, `internet.tele2.se`):

```sh
sudo ./install_sixfab_qmi_service.sh <APN>
```

This script will:

- Install required packages
- Set up a systemd service to automatically bring up the modem connection at boot
- Attempt to connect the modem and log status and diagnostics

### 2. Confirm that it works

After running the script, you can check:

- The status of the service:
  ```sh
  sudo systemctl status sixfab-qmi.service
  ```
- The network interface:
  ```sh
  ifconfig wwan0
  ```
- Try a ping test:
  ```sh
  ping -I wwan0 -c 5 sixfab.com
  ```
- Check the log for details:
  ```sh
  sudo tail -n 40 /var/log/sixfab_qmi_connect.log
  ```

If `wwan0` is up and you can ping, your modem is working!

### 3. Troubleshooting

If it doesn't work, refer to the official Sixfab guide for manual steps and troubleshooting:

- [Sixfab Docs: Setting up a data connection over QMI interface using libqmi](https://docs.sixfab.com/page/setting-up-a-data-connection-over-qmi-interface-using-libqmi)

Some useful manual commands from the guide:

```sh
# Check modem status
sudo qmicli -d /dev/cdc-wdm0 --dms-get-operating-mode

# Set modem online
sudo qmicli -d /dev/cdc-wdm0 --dms-set-operating-mode='online'

# Set raw IP mode
sudo ip link set wwan0 down
echo 'Y' | sudo tee /sys/class/net/wwan0/qmi/raw_ip
sudo ip link set wwan0 up

# Start network (replace <APN> with your APN)
sudo qmicli -p -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='<APN>',ip-type=4" --client-no-release-cid

# Get IP address
sudo udhcpc -q -f -i wwan0
```

If you continue to have issues, check the logs and the official guide for more troubleshooting tips.

## Setting up AWS Session Manager

### Setting up the RPi

TODO

### Setting up your computer

**Add this to your `~/.ssh/config`**

```
# SSH over AWS Systems Manager Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    IdentityFile ~/.ssh/id_rsa
    SetEnv GIT_AUTHOR_NAME=<insert git user name> GIT_AUTHOR_EMAIL=<insert git user email> GIT_COMMITTER_NAME=<insert git user name> GIT_COMMITTER_EMAIL=<insert git user email>
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
    ForwardAgent yes
```

And then connect with `ssh ubuntu@mi-XXXYYYZZZ` where `XXXYYYZZZ` is found in AWS Console.

### Connecting directly to the Raspberry Pi via Ethernet cable

If you want to connect your computer directly to your Raspberry Pi using an Ethernet cable (for fast file transfer, troubleshooting, or when no router is available), follow these steps:

#### About the IP addresses

- The static IP you assign to your **computer's** Ethernet interface (e.g., `10.55.55.1/24`) is the address your Pi will connect to.
- The static IP you assign to your **Raspberry Pi's** Ethernet interface (e.g., `10.55.55.2/24`) is the address your computer will connect to.
- You can use any private subnet (e.g., `192.168.137.x/24`, `10.55.55.x/24`, etc.), just make sure both devices are on the same subnet and the addresses do not conflict with other networks you use.
- The `.1` and `.2` are just a convention; you can use any two addresses in the subnet.

#### 1. Find your Ethernet interface name

On both your computer and the Pi, run:

```bash
ip link
```

Look for an interface that is not `lo` (loopback) or your WiFi (often `wlan0` or `wlp*`). It might be named `eth0`, `enp*`, or `enx*`.

#### 2. Create a new Ethernet connection profile with a descriptive name (recommended)

Suppose your interface is `enxc84d4421f9a5`. Create a profile named "My RPi ethernet":

**On your computer:**

```bash
sudo nmcli connection add type ethernet ifname enxc84d4421f9a5 con-name "My RPi ethernet" ipv4.addresses 10.55.55.1/24 ipv4.method manual
sudo nmcli connection up "My RPi ethernet"
```

**On the Raspberry Pi:**
Suppose your Pi's Ethernet interface is `eth0` (replace if needed):

```bash
sudo nmcli connection add type ethernet ifname eth0 con-name "Direct to PC" ipv4.addresses 10.55.55.2/24 ipv4.method manual
sudo nmcli connection up "Direct to PC"
```

- You can use any descriptive name you like for `con-name`.
- If you use a different adapter in the future, repeat with the new interface name.

#### 3. Test the connection

From your computer:

```bash
ping 10.55.55.2
```

#### 4. SSH into the Pi

From your computer:

```bash
ssh ubuntu@10.55.55.2
```

#### 5. To revert your computer's or Pi's Ethernet interface to DHCP later

**On either side:**

```bash
sudo nmcli connection modify "My RPi ethernet" ipv4.method auto
sudo nmcli connection up "My RPi ethernet"
# or for the Pi
sudo nmcli connection modify "Direct to PC" ipv4.method auto
sudo nmcli connection up "Direct to PC"
```

**Tip:** Interface names can be different on every system. Always use `ip link` to find the correct name for your Ethernet interface on both your computer and the Pi. You can create multiple profiles for different adapters or scenarios, each with a descriptive name for easy management.

### SSH config for direct Ethernet connection

To make it easy to SSH into your Raspberry Pi over Ethernet, add an entry to your `~/.ssh/config` on your computer:

```
Host eth
    HostName 10.55.55.2  # The static IP you assigned to the Pi's Ethernet interface
    User ubuntu
    ForwardAgent yes
    SetEnv GIT_AUTHOR_NAME="Your Name"
    SetEnv GIT_AUTHOR_EMAIL="your.email@example.com"
    SetEnv GIT_COMMITTER_NAME="Your Name"
    SetEnv GIT_COMMITTER_EMAIL="your.email@example.com"
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
```

Now you can simply run:

```bash
ssh eth
```

to connect to your Pi over the direct Ethernet link, with all your environment and agent forwarding settings in place.
