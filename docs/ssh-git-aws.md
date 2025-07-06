# SSH, Git, and AWS CLI Setup

## SSH
- Enable SSH on your Pi:
  ```sh
  sudo systemctl enable --now ssh
  ```
- Add your public key to `~/.ssh/authorized_keys` for passwordless login.

## Git
- Install Git:
  ```sh
  sudo apt install git
  ```
- Set your name and email:
  ```sh
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"
  ```

## AWS CLI
- Install AWS CLI (already included in setup):
  ```sh
  aws --version
  ```
- Configure credentials (if needed for CLI use):
  ```sh
  aws configure
  ```

---
Continue with [Ethernet](ethernet.md) or return to [README](../README.md)
