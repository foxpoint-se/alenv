[⬅ Back to main README](../README.md)

# Setting up Sixfab modem (EG25-G/Quectel)

To set up your Sixfab modem (such as the EG25-G Base HAT) on your Raspberry Pi running Ubuntu 22.04 or similar, follow these steps:

## Script Overview and Folder Structure

All Sixfab modem-related scripts are grouped in `scripts/modem/` for clarity and ease of use:

| Script                              | Purpose                                      | When to Use                |
|------------------------------------- |----------------------------------------------|----------------------------|
| install_sixfab_qmi_service.sh        | Install/configure modem & systemd service    | Initial setup, reconfigure |
| sixfab-watchdog.sh                   | Watchdog: monitor & auto-restart modem       | For reliability            |
| setup-sixfab-watchdog.sh             | Install/uninstall/status for watchdog        | To manage watchdog         |

- **install_sixfab_qmi_service.sh**: Run this first to set up the modem and its systemd service.
- **sixfab-watchdog.sh** & **setup-sixfab-watchdog.sh**: Use these to install a watchdog that keeps the modem connection alive by monitoring and restarting the service as needed.

## 1. Use the install script

Run the following command, replacing `<APN>` with your SIM card's APN (for example, `internet.tele2.se`):

```sh
cd scripts/modem/
sudo ./install_sixfab_qmi_service.sh <APN>
```

This script will:

- Install required packages
- Set up a systemd service to automatically bring up the modem connection at boot
- Attempt to connect the modem and log status and diagnostics

## 2. Confirm that it works

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

## 3. Troubleshooting

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

## 4. Ensuring Modem Reliability with Sixfab Watchdog

If your robot or Pi may lose modem connectivity for extended periods (e.g., underwater, remote), you can install a watchdog service to automatically monitor and restart the Sixfab modem service as needed. This watchdog will keep checking indefinitely and recover as soon as connectivity returns.

### Install the Watchdog

1. Place the `sixfab-watchdog.sh` and `setup-sixfab-watchdog.sh` scripts in `scripts/modem/`.
2. Run the setup script:
   ```sh
   cd scripts/modem/
   sudo ./setup-sixfab-watchdog.sh install
   ```
   - This will:
     - Install/update the `sixfab-watchdog.sh` script to `/usr/local/bin/`
     - Set up a systemd service to run the watchdog on every boot
     - Start the service immediately
   - The script is safe to run multiple times (idempotent).

### Check Status and Logs
- **Service status:**
  ```sh
  sudo ./setup-sixfab-watchdog.sh status
  ```
- **Recent logs:**
  ```sh
  sudo ./setup-sixfab-watchdog.sh logs
  ```
- **Follow logs live:**
  ```sh
  sudo tail -f /var/log/sixfab-watchdog.log
  ```

### Uninstall the Watchdog
To remove the watchdog service:
```sh
sudo ./setup-sixfab-watchdog.sh uninstall
```

### How it works
- The watchdog checks if `wwan0` is up and can reach the internet.
- If not, it restarts the Sixfab modem service (`sixfab-qmi.service` by default).
- All actions are logged to `/var/log/sixfab-watchdog.log`.
- The service is robust to long outages and will keep retrying until connectivity is restored.
