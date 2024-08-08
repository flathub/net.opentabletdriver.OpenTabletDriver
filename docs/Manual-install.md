# Manual setup

Most distros follow the [FHS standard](https://refspecs.linuxfoundation.org/fhs.shtml), if you don't know if your distro follows this standard, it most likely does.

The process of installing udev rules and blacklisting kernel modules may be different on these distros, so you should refer to their documentation on how to install udev rules and kernel module blacklists.

Before following any instructions on this page, if you used a version of OpenTabletDriver below **0.6.3.0** please follow [these](Legacy-cleanup.md) instructions first.

# Installing udev rules

In short, these commands will clone OpenTabletDriver, generate the rules and put them in the respective location and then reload the udev rules.

You are welcome to run these commands individually and inspect anything you like, both the driver and the udev generation script is open source.

```bash
# Download the latest commit of OpenTabletDriver from the official github.
git clone https://github.com/OpenTabletDriver/OpenTabletDriver.git --depth=1
cd OpenTabletDriver
# Run the udev generation script and write the output to /etc/udev/rules.d/
./generate-rules.sh | sudo tee /etc/udev/rules.d/70-opentabletdriver.rules
# Update the udev rules on the system and trigger them.
sudo udevadm control --reload-rules
sudo udevadm trigger
# Cleanup.
cd ..
rm -rf OpenTabletDriver
```

# Blacklisting kernel modules

While this is entirely optional, it is highly recommended if you do not intend to use the systemwide kernel drivers.

If you do need to use them, you can either blacklist and manually modprobe to use the systemwide drivers, or use `rmmod` to unload the drivers when you want to use OpenTabletDriver.

The following commands will tell the system not to load these modules at boot, however they can still be manually loaded.

After running these commands, you may need to refer to your distros documentation on how to rebuild the initramfs, otherwise they may not stick at reboot.

```bash
echo "blacklist wacom" | sudo tee /etc/modprobe.d/99-opentabletdriver.conf
echo "blacklist hid_uclogic" | sudo tee -a /etc/modprobe.d/99-opentabletdriver.conf
```

After running the above commands and rebuilding your initramfs, you can avoid rebooting by running the following commands, however rebooting is highly recommend.

```bash
sudo rmmod wacom hid_uclogic
```

### Fedora Atomic
Disabling modules immutable Fedora spins (Silverblue, Kinoite, Universal Blue, Bazzite, Bluefin, Aurora and etc.) can be done using `rpm-ostree` command:
```
rpm-ostree kargs --append=modprobe.blacklist=hid_uclogic --append=modprobe.blacklist=wacom
```
