#!/bin/bash

# List of essential FHS directories
fhs_dirs=(
  "/bin"
  "/boot"
  "/dev"
  "/etc"
  "/home"
  "/lib"
  "/media"
  "/mnt"
  "/opt"
  "/sbin"
  "/srv"
  "/tmp"
  "/usr"
  "/var"
)

# Allowed missing directories percentage (e.g., 10%)
allowed_missing_percentage=10

# Function to check each directory
check_fhs_compliance() {
    missing_count=0
    total_count=${#fhs_dirs[@]}

    for dir in "${fhs_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "Directory missing: $dir"
            ((missing_count++))
        fi
    done

    # Calculate the allowed number of missing directories
    allowed_missing=$(($total_count * $allowed_missing_percentage / 100))

    if [ ! -d "/etc" ]; then
        echo "/etc directory is missing, which is critical."
        exit 1
    fi

    if [ $missing_count -le $allowed_missing ]; then
        echo "This system adheres to the FHS."
        check_modprobe_d
    else
        echo "This system is missing $missing_count of $total_count essential FHS directories, which is more than allowed."
    fi
}

# Function to check for the existence of modprobe.d
check_modprobe_d() {
    if [ ! -d "/etc/modprobe.d" ]; then
        echo "The /etc/modprobe.d directory does not exist. This system is not compatible."
        exit 1
    else
        manage_kernel_modules
    fi
}

# Function to remove kernel modules and blacklist them
manage_kernel_modules() {
    echo "Removing kernel modules wacom and hid_uclogic..."
    sudo modprobe -r wacom
    sudo modprobe -r hid_uclogic

    echo "Blacklisting kernel modules wacom and hid_uclogic..."
    echo "blacklist wacom" | sudo tee /etc/modprobe.d/99-opentabletdriver.conf
    echo "blacklist hid_uclogic" | sudo tee -a /etc/modprobe.d/99-opentabletdriver.conf

    update_initramfs
}

# Function to update initramfs
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

# Starting the compliance check
check_fhs_compliance

