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
