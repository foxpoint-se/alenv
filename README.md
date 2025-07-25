# Raspberry Pi Cloud-Connected Setup

Welcome! This repository provides a simple, robust way to set up a Raspberry Pi with automatic failover between Wi-Fi and cellular, and reliable remote management via AWS SSM.

## Quick Start

1. **Flash Ubuntu and boot your Pi**
2. **Follow the setup guide:**
   - [Initial Setup](docs/setup.md)
   - [Setup during first session](docs/first-ssh-session.md)
   - [SSH, Git, and AWS](docs/ssh-git-aws.md)
   - [Install dependencies](docs/install-dependencies.md)
   - [Networking & Failover](docs/networking.md)
   - [Ethernet (optional)](docs/ethernet.md)
   - [AWS Session Manager (SSM)](docs/aws-session-manager.md)
   - [ROS 2 setup](docs/ros2-setup.md)

## Features

- Automatic, interface-based failover between Wi-Fi and cellular (no QMI/Sixfab scripts)
- Modern ModemManager/NetworkManager workflow
- Robust SSM agent watchdog for remote management
- Modular scripts for easy install/uninstall

## Legacy

All previous scripts and documentation are archived in the `LEGACY/` folder for reference.
