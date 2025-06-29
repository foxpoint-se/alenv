[⬅ Back to main README](../README.md)

# SSH agent forwarding and Git/AWS user forwarding

## SSH config for your Pi

Add this to your `~/.ssh/config`:

```
Host rpi
    HostName 192.168.XX.XXX  # Your Pi's IP
    User ubuntu
    ForwardAgent yes
    SetEnv GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="your.email@example.com" GIT_COMMITTER_NAME="Your Name" GIT_COMMITTER_EMAIL="your.email@example.com"
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
```

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
