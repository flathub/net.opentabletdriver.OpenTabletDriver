#!/bin/bash

# Define the quirks file path
QUIRKS_FILE="/etc/libinput/local-overrides.quirks"

# Define the content to be added
QUIRKS_CONTENT="[OpenTabletDriver Virtual Tablet]
MatchName=OpenTabletDriver*
AttrTabletSmoothing=0"

# Check if the quirks file exists
if [ ! -f "$QUIRKS_FILE" ]; then
    echo "Creating quirks file at $QUIRKS_FILE"
    sudo touch "$QUIRKS_FILE"
fi

# Add the content to the quirks file
echo "Adding tablet smoothing override to $QUIRKS_FILE"
echo "$QUIRKS_CONTENT" | sudo tee -a "$QUIRKS_FILE" > /dev/null
sudo systemctl restart opentabletdriver.service

echo "Configuration updated."