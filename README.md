# OpenTabletDriver Flatpak Package

Welcome to the unofficial Flatpak package for OpenTabletDriver! This Flatpak package, `net.opentabletdriver.OpenTabletDriver`, is maintained by an independent developer passionate about making OpenTabletDriver more accessible and easier to install on Linux distributions. While this is not an official package from the OpenTabletDriver project team, it aims to deliver the same great user experience and functionality.

## About OpenTabletDriver

OpenTabletDriver is an open-source, cross-platform tablet driver offering high compatibility and performance for a wide range of graphics tablets. It features an easily configurable graphical user interface, making it possible for users to fine-tune their tablets to match their exact needs. OpenTabletDriver supports absolute and relative cursor positioning, pen bindings, and even custom plugins for enhanced functionality.

## Installation

### Prerequisites
Before installing OpenTabletDriver, you need to set up Flatpak on your system. Follow the [pre-installation guide provided](https://github.com/flathub/net.opentabletdriver.OpenTabletDriver/blob/docs/Pre-installation.md).

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

This command starts the OpenTabletDriver daemon and, if you choose to use it, the GUI for configuring your tablet settings. Remember, the daemon must be running for tablet functionality, but the GUI is optional and used only for configuration purposes.
