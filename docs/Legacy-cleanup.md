# Removing remnants of legacy packages

If you have previously used a legacy package of OpenTabletDriver, it is highly recommended that you follow the instructions here.

Even if you aren't sure that you have, this is non destructive and cannot damage your system in any way.

# FHS-Distros

Most distros follow the FHS standard, if you don’t know if your distro follows this standard, it most likely does.

## Removing obsolete udev rules

Please run the following script in bash, alternatively you may check the directories listed for the aforementioned files.


After running this script you may be required to rebuild your initramfs for this to apply, at boot. Refer to your distros documentation for the correct commands.

```bash
echo "Finding old udev rules..."
for c in /etc/udev/rules.d/9{0,9}-opentabletdriver.rules; do
  if [ -f "${c}" ]; then
    echo "Deleting ${c}"
    sudo rm "${c}"
  fi
done

# Reload system configuration.
sudo udevadm control --reload-rules && sudo udevadm trigger

```

# Non-FHS distro

Refer to your distro’s documentation on how to remove udev rules of the name `90-opentabletdriver.rules` or `99-opentabletdriver.rules`.