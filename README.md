# Alenv

Various things for the Eel's host environment.

## Network

**Ålen**

`/etc/netplan/50-cloud-init.yaml`

```yaml
# ÅLEN
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      optional: true
      addresses:
        - 192.168.0.101/24
  wifis:
    wlan0:
      dhcp4: true
      optional: true
      access-points:
        my-wifi:
          password: REDACTED
      addresses:
        - 192.168.1.118/24
```

**Tvålen**

`/etc/netplan/50-cloud-init.yaml`

```yaml
# TVÅLEN
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      optional: true
  wifis:
    wlan0:
      dhcp4: true
      optional: true
      access-points:
        my-wifi:
          password: REDACTED
      addresses:
        - 192.168.1.242/24
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1, 192.168.1.1]
```

## SSH config

**Your computer**

`~/.ssh/config`

```
# SSH over AWS Systems Manager Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    IdentityFile ~/.ssh/id_rsa
    SetEnv GIT_AUTHOR_NAME=<insert git user name> GIT_AUTHOR_EMAIL=<insert git user emal> GIT_COMMITTER_NAME=<insert git user name> GIT_COMMITTER_EMAIL=<insert git user email>
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
    ForwardAgent yes

# On home network
Host alpha-gun
    HostName 192.168.0.118
    User ubuntu
    ForwardAgent yes
    SetEnv GIT_AUTHOR_NAME=<insert git user name> GIT_AUTHOR_EMAIL=<insert git user emal> GIT_COMMITTER_NAME=<insert git user name> GIT_COMMITTER_EMAIL=<insert git user emal>
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL

# Another one on home network
Host alpha-gun-1
    HostName 192.168.1.118
    User ubuntu
    ForwardAgent yes
    SetEnv GIT_AUTHOR_NAME=<insert git user name> GIT_AUTHOR_EMAIL=<insert git user emal> GIT_COMMITTER_NAME=<insert git user name> GIT_COMMITTER_EMAIL=<insert git user emal>
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL

# Over cable
Host alpha-gun-eth
    HostName 192.168.0.101
    User ubuntu
    ForwardAgent yes
    SetEnv GIT_AUTHOR_NAME=<insert git user name> GIT_AUTHOR_EMAIL=<insert git user emal> GIT_COMMITTER_NAME=<insert git user name> GIT_COMMITTER_EMAIL=<insert git user emal>
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
```
