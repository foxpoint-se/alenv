[⬅ Back to main README](../README.md)

# ROS2 Setup

## Following official installation guide

- Humble: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html
- OR Jazzy: https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html

You probably don't need GUI tools, so `ros-$ROS_DISTRO-ros-base` should be enough. However, you might want to install demo packages, just to verify that everything is working as expected:

```bash
sudo apt update
sudo apt install ros-$ROS_DISTRO-demo-nodes-cpp
sudo apt install ros-$ROS_DISTRO-demo-nodes-py
```

## Verify that it works

```bash
source /opt/ros/$ROS_DISTRO/setup.bash
ros2 run demo_nodes_cpp talker
```

And in another terminal:

```bash
source /opt/ros/$ROS_DISTRO/setup.bash
ros2 run demo_nodes_py listener
```

If you see these nodes talking to each other, you're all set!

## ROS2 Control (optional, not required for Eel as of yet)

To install ROS2 Control, run:

```bash
sudo apt install ros-$ROS_DISTRO-ros2-control ros-$ROS_DISTRO-ros2-controllers
```

Remember to `source /opt/ros/$ROS_DISTRO/setup.bash` again, now that you have new packages.

Install xacro: `sudo apt install ros-$ROS_DISTRO-xacro`
