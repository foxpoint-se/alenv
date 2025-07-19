[⬅ Back to main README](../README.md)

# ROS2 Setup

## Following official installation guide

Assuming you want to install ROS2 Humble, follow the steps here:

- Humble: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html
- OR Jazzy: https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html

You probably don't need GUI tools, so `ros-humble-ros-base` should be enough. However, you might want to install demo packages, just to verify that everything is working as expected:

```bash
sudo apt update
sudo apt install ros-$ROS_DISTRO-demo-nodes-cpp
sudo apt install ros-$ROS_DISTRO-demo-nodes-py
```

## Verify that it works

```bash
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp talker
```

And in another terminal:

```bash
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_py listener
```

If you see these nodes talking to each other, you're all set!

## ROS2 Control (optional, not requierd for Eel as of yet)

To install ROS2 Control, run:

```bash
sudo apt install ros-humble-ros2-control ros-humble-ros2-controllers
```

Remember to `source /opt/ros/humble/setup.bash` again, now that you have new packages.

Install xacro: `sudo apt install ros-humble-xacro`
