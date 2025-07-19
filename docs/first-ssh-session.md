[⬅ Back to main README](../README.md)

# Setup during first SSH session

## Modify your SSH config

On your desktop computer:

1. Add this to your `~/.ssh/config`:
   ```bash
   Host anyhostname
   HostName 192.168.XX.YYY
   User ubuntu
   ForwardAgent yes
   SetEnv GIT_AUTHOR_NAME="mygitusername" GIT_AUTHOR_EMAIL="myemail@example.com" GIT_COMMITTER_NAME="mygitusername" GIT_COMMITTER_EMAIL="myemail@example.com"
   SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
   ```
1. Now you can easily access the RPi with `ssh anyhostname`

## Login and update

On the RPi:

```bash
sudo apt update && sudo apt upgrade -y
```

## Install core dependencies

On the RPi:

```bash
sudo apt install network-manager modemmanager awscli jq
```

Go back to start page and find the next step.

[⬅ Back to main README](../README.md)
