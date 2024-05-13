# Pre-installation instructions

To get OpenTabletDriver running, certain systemwide changes must be made to allow OpenTabletDriver access to the tablet while also preventing the default kernel drivers from using the tablet.

This does mean that by following these instructions you prevent the systemwide driver from accessing the tablet, so you must have OpenTabletDriver running to use it.

If you intend to use OpenTabletDriver for everything, you should install the udev rules and the kernel driver blacklists, if you intend to use the system driver occassionally, alongside OpenTabletDriver, you may not want to install the blacklists, but you'll still need the udev rules.

Installing the blacklists means that OTD will work automatically without the need to run any commands at boot, however any time you would prefer to use the kernel drivers, you would need to load them.
```bash
sudo modprobe wacom hid_uclogic
```

Not installing the blacklists will mean that the system drivers will work automatically, but to use OpenTabletDriver you will need to unload them. Here is a command you can use to unload the kernel drivers.
```sh
sudo rmmod wacom hid_uclogic
```

# Automatic setup

Most distros follow the [FHS standard](https://refspecs.linuxfoundation.org/fhs.shtml), if you don't know if your distro follows this standard, it most likely does.

You cannot use these scripts on distros that do not support the FHS standard, you must refer to their documentation on how to install blacklists for kernel modules and how to install udev rules.

These scripts assume that you have not used a legacy package of OpenTabletDriver before, if you used a version below **0.6.3.0** please follow [these](Legacy-cleanup.md) instructions first.



```sh
# Install udev rules, this is required for OTD to function.
curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/scripts/setup-udev.sh | bash
# This is optional, but not blacklisting modules means you'll have to `rmmod` every time to use OpenTabletDriver.
curl -s https://raw.githubusercontent.com/flathub/net.opentabletdriver.OpenTabletDriver/scripts/setup-module.sh | bash 
```



# Manual Setup

If you prefer to do the systemwide changes manually, we have a dedicated page [here](Manual-install.md).
