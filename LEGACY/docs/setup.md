[⬅ Back to main README](../README.md)

# Initial Setup & Imaging

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
