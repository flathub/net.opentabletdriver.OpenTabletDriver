#!/bin/bash

# Remove OpenTabletDriver udev rules if exists
if [ -f "/etc/udev/rules.d/70-opentabletdriver.rules" ]; then
    echo "Removing OpenTabletDriver udev rules..."
    sudo rm -f /etc/udev/rules.d/70-opentabletdriver.rules
else
    echo "OpenTabletDriver udev rules file does not exist."
fi

# Remove OpenTabletDriver modprobe configuration if exists
if [ -f "/etc/modprobe.d/99-opentabletdriver.conf" ]; then
    echo "Removing OpenTabletDriver modprobe configuration..."
    sudo rm -f /etc/modprobe.d/99-opentabletdriver.conf
else
    echo "OpenTabletDriver modprobe configuration file does not exist."
fi

# Remove specific blacklist entries if file exists
blacklist_file="/etc/modprobe.d/blacklist.conf"
if [ -f "$blacklist_file" ]; then
    echo "Checking for blacklist entries to remove..."
    if grep -q "blacklist wacom" "$blacklist_file"; then
        sudo sed -i '/blacklist wacom/d' "$blacklist_file"
        echo "Removed 'blacklist wacom' from blacklist.conf"
    fi
    if grep -q "blacklist hid_uclogic" "$blacklist_file"; then
        sudo sed -i '/blacklist hid_uclogic/d' "$blacklist_file"
        echo "Removed 'blacklist hid_uclogic' from blacklist.conf"
    fi
else
    echo "Blacklist configuration file does not exist."
fi

# Function to determine which initramfs tool to use
update_initramfs() {
    if command -v update-initramfs &> /dev/null; then
        echo "Using update-initramfs to update initramfs..."
        sudo update-initramfs -u
    elif command -v dracut &> /dev/null; then
        echo "Using dracut to regenerate initramfs..."
        sudo dracut -f
    elif command -v mkinitcpio &> /dev/null; then
        echo "Using mkinitcpio to regenerate all initramfs..."
        sudo mkinitcpio -P
    else
        echo "No known initramfs update tool found."
    fi
}

# Reload udev rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# Update initramfs according to the system's available tools
update_initramfs

