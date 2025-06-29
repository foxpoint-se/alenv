[⬅ Back to main README](../README.md)

# Setting up Sixfab modem (EG25-G/Quectel)

To set up your Sixfab modem (such as the EG25-G Base HAT) on your Raspberry Pi running Ubuntu 22.04 or similar, follow these steps:

## 1. Use the install script

Run the following command, replacing `<APN>` with your SIM card's APN (for example, `internet.tele2.se`):

```sh
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
