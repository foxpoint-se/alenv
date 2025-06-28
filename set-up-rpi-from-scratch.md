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

1. Generate password hash: `wpa_passphrase "SSID" "password"`
1. Create new config: `sudo nano /etc/netplan/99-wifi-config.yaml`
1. Add configuration:
   ```yaml
   network:
     version: 2
     wifis:
       wlan0:
         dhcp4: true
         optional: true
         access-points:
           "SSID":
             password: "hash_from_step_1"
   ```
1. Limit permissions of created file: `sudo chmod 600 /etc/netplan/99-wifi-config.yaml`
1. Check that it's valid: `sudo netplan generate`
1. If you get no output, everything should be fine. Now apply: `sudo netplan apply`

### Configuring 4G modem (Quectel)

1. Install required packages: `sudo apt install modemmanager`
1. Enable and start ModemManager: `sudo systemctl enable ModemManager && sudo systemctl start ModemManager`
1. Check modem status: `sudo mmcli -L`
1. Get modem details: `sudo mmcli -m 0` (replace 0 with modem index from step 3)
1. Create 4G config: `sudo nano /etc/netplan/98-4g-modem.yaml`
1. Add configuration:
   ```yaml
   network:
     version: 2
     modems:
       wwan0:
         apn: "internet" # Replace with your carrier's APN, like internet.tele2.se
         dhcp4: true
         optional: true
   ```
1. Set permissions: `sudo chmod 600 /etc/netplan/98-4g-modem.yaml`
1. Apply configuration: `sudo netplan generate && sudo netplan apply`

**Common APN settings:**

- Telia (Sweden): `online.telia.se`
- Telenor (Sweden): `internet`
- Tele2 (Sweden): `internet.tele2.se`
- Generic: `internet`

**Troubleshooting:**

- Check modem status: `sudo mmcli -m 0 --simple-status`
- Check connection: `sudo mmcli -m 0 --3gpp-ussd-status`
- Monitor network: `sudo networkctl status wwan0`
