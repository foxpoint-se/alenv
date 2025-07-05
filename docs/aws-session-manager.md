[⬅ Back to main README](../README.md)

# Setting up AWS Session Manager

## Setting up the RPi

To enable AWS Session Manager on your Raspberry Pi (Ubuntu), follow these steps:

### Prerequisites
- Your Pi must have outbound internet access (to reach AWS endpoints).
- You need an AWS account with permissions to create SSM Hybrid Activations.
- Know your Pi's architecture: run `uname -m` (look for `aarch64`/`arm64` for 64-bit, `armv7l`/`armhf` for 32-bit).

### 1. Update and install prerequisites
```sh
sudo apt update
sudo apt install -y curl unzip jq
```

### 2. Install the AWS SSM Agent
(https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-deb.html).

#### For ARM64 (aarch64/arm64):
```sh
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_arm64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
```

#### For ARMHF (armv7l/armhf):
```sh
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_armhf/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
```

### 3. Enable and start the agent
```sh
sudo systemctl stop amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
```

### 4. Install AWS CLI
This is useful for diagnostics and hybrid activation, but not strictly required for the agent to run:
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
> For 32-bit, see the [official AWS CLI v2 ARMv6/v7 instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### 5. Register as a Hybrid Managed Instance (if not on EC2)
- Go to [AWS SSM Hybrid Activations](https://console.aws.amazon.com/systems-manager/managed-instances/activations) and create an activation.
- On your Pi, run:
  ```sh
  sudo amazon-ssm-agent -register -code <ActivationCode> -id <ActivationId> -region <region>
  ```

### 6. Check agent status
```sh
sudo systemctl status amazon-ssm-agent
sudo tail -n 40 /var/log/amazon/ssm/amazon-ssm-agent.log
```

### Troubleshooting tips
- If the agent fails to start, check `/var/log/amazon/ssm/amazon-ssm-agent.log`.
- Make sure your Pi's clock is correct (NTP), as AWS authentication is time-sensitive.
- Make sure you use the correct architecture (arm64 vs armhf) for your OS.
- The Pi must have outbound internet access to AWS SSM endpoints.

---

Once registered, your Pi will appear as a managed instance in the AWS SSM console, and you can connect to it using Session Manager from the AWS Console or AWS CLI.

> For more details, see the [official AWS documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-deb.html).

## Ensuring SSM Agent Waits for Modem (wwan0) Before Starting

If your Pi uses a cellular modem (wwan0) for connectivity, the SSM agent may start before the modem is ready, causing unreliable connections. To fix this, use the provided scripts to ensure the SSM agent only starts after the modem is up and has internet access.

### One-time Setup (Idempotent)

1. Run the setup script:
    ```sh
    cd ./scripts/ssm/service-fix/
    ./setup-ssm-wait-for-wwan.sh
    ```
    - This will:
      - Install/update the `wait-for-wwan.sh` script to `/usr/local/bin/`
      - Set up a systemd override so the SSM agent waits for the modem
      - Reload and restart the SSM agent
    - The script is safe to run multiple times (idempotent).

3. **Reboot and test:**
    - Disconnect WiFi, reboot, and ensure the SSM agent connects over the modem.

### Viewing Logs
- The output from `wait-for-wwan.sh` is included in the SSM agent's systemd logs:
    ```sh
    sudo journalctl -u amazon-ssm-agent -b
    ```
- Look for lines containing `wait-for-wwan.sh` to see the modem wait status.

### Troubleshooting
- If the SSM agent does not connect, check:
    - The modem is up and has a route to the internet
    - The logs above for timeout or error messages
- You can safely re-run the setup script if you update the scripts or need to re-apply the fix.

## Ensuring SSM Agent Robustness with Watchdog

If your Pi may lose connectivity for extended periods, install the SSM watchdog service to automatically monitor and restart the SSM agent as needed. The watchdog will keep checking indefinitely and recover as soon as connectivity returns.

### Install the Watchdog

```sh
cd ./scripts/ssm/service-fix/
sudo ./setup-ssm-watchdog.sh --status
```
- This installs, enables, and starts the watchdog service.
- The service will run on every boot and continuously monitor SSM connectivity.

### Check Status and Logs
- **Service status:**
  ```sh
  sudo systemctl status ssm-watchdog.service
  ```
- **Recent logs:**
  ```sh
  sudo ./scripts/ssm/service-fix/setup-ssm-watchdog.sh --logs
  ```
- **Follow logs live:**
  ```sh
  sudo journalctl -u ssm-watchdog.service -f
  ```

### Uninstall the Watchdog
To remove the watchdog service:
```sh
sudo systemctl stop ssm-watchdog.service
sudo systemctl disable ssm-watchdog.service
sudo rm /usr/local/bin/ssm-watchdog.sh
sudo rm /etc/systemd/system/ssm-watchdog.service
sudo systemctl daemon-reload
```

## Setting up your computer

To use SSH over AWS Session Manager (with the ProxyCommand in your SSH config), you must install the AWS Session Manager Plugin on your local machine (not the Pi).

### Install the Session Manager Plugin

#### On Linux (x86_64):
```sh
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

### Verify installation
```sh
session-manager-plugin --version
```
You should see a version number.

---

### SSH using proxy command
Add this to your `~/.ssh/config`:

```
# SSH over AWS Systems Manager Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    IdentityFile ~/.ssh/id_rsa
    SetEnv GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="your.email@example.com" GIT_COMMITTER_NAME="Your Name" GIT_COMMITTER_EMAIL="your.email@example.com"
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
    ForwardAgent yes
```

And then connect with `ssh ubuntu@mi-XXXYYYZZZ` where `XXXYYYZZZ` is found in AWS Console, or by using `./scripts/ssm/list-managed.nodes.sh`.

