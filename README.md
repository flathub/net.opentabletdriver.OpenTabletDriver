# OpenTabletDriver Flatpak Package

Welcome to the unofficial Flatpak package for OpenTabletDriver! This Flatpak package, `net.opentabletdriver.OpenTabletDriver`, is maintained by an independent developer passionate about making OpenTabletDriver more accessible and easier to install on Linux distributions. While this is not an official package from the OpenTabletDriver project team, it aims to deliver the same great user experience and functionality.

Because OpenTabletDriver requires access to the tablet, it requires systemwide permission changes. If you do not have access to root, you cannot use this package.

Using this package means that you are solely resposible for maintaining and updating the udev rules when you update the driver. This cannot be managed by the flatpak package.

Because of this it is better for most people to use the official packages where possible. You can find the official installation instructions on their [website](https://opentabletdriver.net).

## About OpenTabletDriver

OpenTabletDriver is an open-source, cross-platform tablet driver offering high compatibility and performance for a wide range of graphics tablets. It features an easily configurable graphical user interface, making it possible for users to fine-tune their tablets to match their exact needs. OpenTabletDriver supports absolute and relative cursor positioning, pen bindings, and even custom plugins for enhanced functionality.

## Installation

### Prerequisites

For OpenTabletDriver to function correctly, you must install udev rules and blacklist some kernel modules. Follow the [pre-installation guide](docs/Pre-installation.md) for instructions on how to do this. OpenTabletDriver will **not** function without without doing this.

### Installation

#### 1. Setup Flatpak

Ensure Flatpak is installed on your system. If it is not already installed, you can install it by following the instructions specific to your operating system on the [Flatpak official website](https://flatpak.org/setup/).

#### 2. Install OpenTabletDriver

With Flatpak and the Flathub repository set up, you can now install OpenTabletDriver. Execute the following command in your terminal:

```bash
flatpak install flathub net.opentabletdriver.OpenTabletDriver
```

## Running OpenTabletDriver

After installation, OpenTabletDriver can be launched from your application menu or via the terminal with the following command:

```bash
flatpak run net.opentabletdriver.OpenTabletDriver
```

This command starts the OpenTabletDriver daemon and the GUI for configuring your tablet settings. Remember, the daemon must be running for tablet functionality, but the GUI is optional and used only for configuration purposes.

To only launch the driver, run:
```bash
flatpak run net.opentabletdriver.OpenTabletDriver -d
```

### Running as a daemon

If you want to start a driver at login, set up a user-level systemd service using the following steps:
```bash
mkdir -p ~/.config/systemd/user/
curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/scripts/opentabletdriver.service > ~/.config/systemd/user/opentabletdriver.service
systemctl --user daemon-reload
systemctl --user restart opentabletdriver.service
``` 

# Updating OpenTabletDriver

You can update this package either by calling `flatpak update` to update every package or directly specifying this package.

```bash
flatpak update net.opentabletdriver.OpenTabletDriver
```

Once complete, you should follow the [pre-installation guide](docs/Pre-installation.md) again to update the udev rules.
