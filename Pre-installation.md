# Pre-installation instructions
To get OpenTabletDriver running, certain systemwide changes must be made to allow OTD to use the tablet while also preventing the default kernel drivers from using this tablet.

This does mean that by following these instructions you prevent the systemwide driver from accessing the tablet, if you still need to use these then you should only install the udev rules and manually unload the kernel drivers when you want to use your tablet with OpenTabletDriver.

For scripts that automatically handle everything, see [here](Automatic-install.md), for manual setup, see below.

<!--
Here we should probably include a mention of upgrading from legacy installations of OTD, or upgrading OTD in general.
Rule updates may be required for users when they have tablets that have been supported in the following release, but not in a release when they installed the rules.
-->

# 1. Kernel module setup
OpenTabletDriver conflicts with two kernel modules: `wacom` and `hid_uclogic`. To ensure proper operation of OpenTabletDriver, we need to blacklist these two kernel modules.

To blacklist specific kernel modules such as wacom and hid_uclogic, you need to modify or create some configuration files to instruct the operating system not to load these modules during startup. Below are the specific methods for several major Linux distributions:

## 1.1  For FHS distro

### 1.1.1 Manually
```sh
sudo vim /etc/modprobe.d/99-opentabletdriver.conf
```
Then you should add the following content to it:
```
blacklist wacom
blacklist hid_uclogic
```
Save the file and exit the editor.

After this, run:

`sudo modprobe uinput`

Then you need to update the initramfs, which can be done using different methods depending on the distribution. Below are three common commands for updating the initramfs:
```bash
sudo update-initramfs -u
sudo dracut -f
sudo mkinitcpio -P
```
### 1.1.2 Automated method

Just run

`curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/scripts/setup-module.sh | sudo bash
`


## 1.2  For non-FHS distroNon-FHS distro

Refer to your distro’s documentation on how to remove udev rules of the name 90-opentabletdriver.rules or 99-opentabletdriver.rules and a kernel module blacklist named blacklist.conf containing:
```
blacklist wacom
blacklist hid_uclogic
```
If there is no updated package available for your distro, you may try building from source. Consult your distro’s documentation on how to “install” the resulting generic binary tarball.

# 2. Set up udev rules

In Linux systems, udev is a daemon responsible for managing device nodes. It allows you to run scripts or programs based on device events such as device addition or removal. udev rules can be used to change device permissions, run specific programs or scripts, set environment variables, and more. Therefore, for OpenTabletDriver to function properly, correct udev rules must be set up.

## 2.1 Automated method

Just run

`curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/scripts/setup-udev.sh | sudo bash`

## 2.2 Manually

#### 1. Clone the OpenTabletDriver Repository

```bash
git clone https://github.com/OpenTabletDriver/OpenTabletDriver.git --depth=1
```
#### 2. Enter the Repository Directory and Generate New udev Rules

```bash
cd OpenTabletDriver
./generate-rules.sh
```

#### 3. Add the Generated udev Rules to the System
Output the generated udev rules to the `/etc/udev/rules.d/70-opentabletdriver.rules` file:
```bash
./generate-rules.sh | sudo tee /etc/udev/rules.d/70-opentabletdriver.rules
```
#### 4. Reload udev Rules And Cleanup
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
cd ..
rm -rf OpenTabletDriver
```

# 3. Uninstallation
## 3.1 Automated method
Just run:

`curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/scripts/revert-changes.sh | sudo bash
`