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

    if [ $missing_count -le $allowed_missing ]; then
        echo "This system adheres to the FHS."
        check_udev_directory
    else
        echo "This system is missing $missing_count of $total_count essential FHS directories, which is more than allowed."
    fi
}

# Function to check for udev directory and run additional scripts
check_udev_directory() {
    if [ -d "/etc/udev" ]; then
        echo "Finding old udev rules..."
        for c in /etc/udev/rules.d/9{0,9}-opentabletdriver.rules; do
            if [ -f "${c}" ]; then
                echo "Deleting ${c}"
                sudo rm "${c}"
            fi
        done

        git clone https://github.com/OpenTabletDriver/OpenTabletDriver.git --depth=1
        cd OpenTabletDriver

        ./generate-rules.sh | sudo tee /etc/udev/rules.d/70-opentabletdriver.rules

        cd ..
        rm -rf OpenTabletDriver

        sudo udevadm control --reload-rules && sudo udevadm trigger
    else
        echo "/etc/udev directory does not exist. Skipping udev rule management."
    fi
}

# Run the check
check_fhs_compliance

