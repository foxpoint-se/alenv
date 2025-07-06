[⬅ Back to main README](../README.md)

# Initial Setup

1. **Flash Ubuntu 22.04+ to your SD card**
   - Use the official Raspberry Pi Imager or Balena Etcher.
   - Insert the SD card and boot your Pi.

2. **Login and update**
   ```sh
   sudo apt update && sudo apt upgrade -y
   ```

3. **Install core dependencies**
   ```sh
   sudo apt install network-manager modemmanager awscli jq tmux
   ```

4. **(Optional) Enable SSH**
   - Create an empty file named `ssh` in the boot partition before first boot, or enable via `sudo systemctl enable --now ssh`.

5. **Continue with [Networking & Failover](networking.md)**
