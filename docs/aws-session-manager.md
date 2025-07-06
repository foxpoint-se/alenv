[⬅ Back to main README](../README.md)

# AWS Session Manager (SSM)

## Overview
AWS SSM lets you securely manage and access your Pi remotely, even behind NAT or with dynamic IPs.

## 1. Install the SSM Agent
```sh
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service
```

## 2. Register as a Hybrid (On-Prem) Instance
- Follow the AWS docs to create an activation code and ID for your account/region.
- Register your Pi:
  ```sh
  sudo amazon-ssm-agent -register -code <activation-code> -id <activation-id> -region <region>
  ```
- The instance will appear in the AWS SSM console.

## 3. Install the SSM Watchdog (Recommended)
This script ensures the SSM agent is always running and has valid credentials and connectivity, even after long outages or network changes.

```sh
cd scripts/ssm
sudo ./setup-ssm-watchdog.sh --status
```
- This installs, enables, and starts the watchdog service.
- The service will run on every boot and continuously monitor SSM connectivity.

## 4. Check Status and Logs
- **Service status:**
  ```sh
  sudo systemctl status ssm-watchdog.service
  ```
- **Recent logs:**
  ```sh
  sudo ./setup-ssm-watchdog.sh --logs
  ```
- **Follow logs live:**
  ```sh
  sudo journalctl -u ssm-watchdog.service -f
  ```

## 5. Troubleshooting
- If the agent fails to connect, check `/var/log/amazon/ssm/amazon-ssm-agent.log` and the watchdog logs.
- Ensure your Pi's clock is correct (NTP).
- Make sure you have outbound internet access to AWS endpoints.

---
Continue with [SSH, Git, and AWS](ssh-git-aws.md)

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

