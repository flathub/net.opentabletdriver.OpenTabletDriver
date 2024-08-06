#!/bin/bash

# Check arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--daemon-only)
      DAEMON_ONLY=1
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      echo "Usage: -d|--daemon-only    Do not start configuration utility, only the driver"
      exit 1
      ;;
  esac
done

if [[ $DAEMON_ONLY != 1 ]]
then
  # Check if OpenTabletDriver.Daemon is running
  if ! ps ax | grep -v grep | grep "OpenTabletDriver.Daemon" > /dev/null
    then
      echo "OpenTabletDriver.Daemon is not running, starting it now..."
      # Start Daemon from the current directory
echo      "/app/bin/OpenTabletDriver.Daemon &"
    else
      echo "OpenTabletDriver.Daemon is already running."
    fi
    # Start OpenTabletDriver.UX.Gtk with exec, replacing the current shell
    echo "Starting OpenTabletDriver.UX.Gtk with exec..."
echo    exec /app/bin/OpenTabletDriver.UX.Gtk
else
    echo "Running only the driver daemon"
    # Start OpenTabletDriver with exec, replacing the current shell
echo    exec /app/bin/OpenTabletDriver.Daemon
fi
