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

## SSH login banner

1. Google for "ascii text generator" and create your ASCII text
1. Copy that
1. Edit the "message of the day" with `sudo nano /etc/motd`
1. Paste your ASCII art here. Save and close.
1. Log out and in again, to confirm it works.

## SSH server config on the Pi

Edit `/etc/ssh/sshd_config`:

```
AcceptEnv GIT_*
AcceptEnv AWS_*
```

Restart SSH:

```bash
sudo systemctl restart ssh
```

## Test the setup

```bash
# On your local machine
ssh-add -l

# SSH to Pi and test
ssh rpi
ssh-add -l  # Should show your forwarded keys
echo $GIT_AUTHOR_NAME  # Should show your name
echo $GIT_AUTHOR_EMAIL  # Should show your email
```

## Use AWS credentials

If you're using `aws-vault`, you'll have AWS environment variables active. So make sure to have an AWS vault profile active when SSH:ing into the RPi, if you need to access AWS from there.

Go back to start page and find the next step.

[⬅ Back to main README](../README.md)
