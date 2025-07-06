[⬅ Back to main README](../README.md)

# Connecting directly to the Raspberry Pi via Ethernet cable

If you want to connect your computer directly to your Raspberry Pi using an Ethernet cable (for fast file transfer, troubleshooting, or when no router is available), follow these steps:

#### About the IP addresses

- The static IP you assign to your **computer's** Ethernet interface (e.g., `10.55.55.1/24`) is the address your Pi will connect to.
- The static IP you assign to your **Raspberry Pi's** Ethernet interface (e.g., `10.55.55.2/24`) is the address your computer will connect to.
- You can use any private subnet (e.g., `192.168.137.x/24`, `10.55.55.x/24`, etc.), just make sure both devices are on the same subnet and the addresses do not conflict with other networks you use.
- The `.1` and `.2` are just a convention; you can use any two addresses in the subnet.

#### 1. Find your Ethernet interface name

On both your computer and the Pi, run:

```bash
ip link
```

Look for an interface that is not `lo` (loopback) or your WiFi (often `wlan0` or `wlp*`). It might be named `eth0`, `enp*`, or `enx*`.

#### 2. Create a new Ethernet connection profile with a descriptive name (recommended)

Suppose your interface is `enxc84d4421f9a5`. Create a profile named "My RPi ethernet":

**On your computer:**

```bash
sudo nmcli connection add type ethernet ifname enxc84d4421f9a5 con-name "My RPi ethernet" ipv4.addresses 10.55.55.1/24 ipv4.method manual
sudo nmcli connection up "My RPi ethernet"
```

**On the Raspberry Pi:**
Suppose your Pi's Ethernet interface is `eth0` (replace if needed):

```bash
sudo nmcli connection add type ethernet ifname eth0 con-name "Direct to PC" ipv4.addresses 10.55.55.2/24 ipv4.method manual
sudo nmcli connection up "Direct to PC"
```

- You can use any descriptive name you like for `con-name`.
- If you use a different adapter in the future, repeat with the new interface name.
- If you prefer, you can use the original example subnet (`192.168.137.1/24` and `192.168.137.2/24`).

#### 3. Test the connection

From your computer:

```bash
ping 10.55.55.2
```

#### 4. SSH into the Pi

From your computer:

```bash
ssh ubuntu@10.55.55.2
```

#### 5. To revert your computer's or Pi's Ethernet interface to DHCP later

**On either side:**

```bash
sudo nmcli connection modify "My RPi ethernet" ipv4.method auto
sudo nmcli connection up "My RPi ethernet"
# or for the Pi
sudo nmcli connection modify "Direct to PC" ipv4.method auto
sudo nmcli connection up "Direct to PC"
```

**Tip:** Interface names can be different on every system. Always use `ip link` to find the correct name for your Ethernet interface on both your computer and the Pi. You can create multiple profiles for different adapters or scenarios, each with a descriptive name for easy management.

### SSH config for direct Ethernet connection

To make it easy to SSH into your Raspberry Pi over Ethernet, add an entry to your `~/.ssh/config` on your computer:

```
Host eth
    HostName 10.55.55.2  # The static IP you assigned to the Pi's Ethernet interface
    User ubuntu
    ForwardAgent yes
    SetEnv GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="your.email@example.com" GIT_COMMITTER_NAME="Your Name" GIT_COMMITTER_EMAIL="your.email@example.com"
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
```

Now you can simply run:

```bash
ssh eth
```

to connect to your Pi over the direct Ethernet link, with all your environment and agent forwarding settings in place.
