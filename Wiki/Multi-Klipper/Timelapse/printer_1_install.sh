#!/bin/bash
# Moonraker Timelapse component installer
#
# Copyright (C) 2021 Christoph Frei <fryakatkop@gmail.com>
# Copyright (C) 2021 Stephan Wendel aka KwadFan <me@stephanwe.de>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
#
# Note:
# this installer script is heavily inspired by 
# https://github.com/protoloft/klipper_z_calibration/blob/master/install.sh

# Prevent running as root.
if [ ${UID} == 0 ]; then
    echo -e "DO NOT RUN THIS SCRIPT AS 'root' !"
    echo -e "If 'root' privileges needed, you will prompted for sudo password."
    exit 1
fi

# Force script to exit if an error occurs
set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/ && pwd )"

# Default Parameters
MOONRAKER_TARGET_DIR="${HOME}/moonraker/moonraker/components"
SYSTEMDDIR="/etc/systemd/system"
KLIPPER_CONFIG_DIR="${HOME}/klipper_config/printer_1"
FFMPEG_BIN="/usr/bin/ffmpeg"

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function stop_klipper {
    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F "klipper-1.service")" ]; then
        echo "Klipper service found! Stopping during Install."
        sudo systemctl stop klipper-1
    else
        echo "Klipper service not found, please install Klipper first"
        exit 1
    fi
}

function stop_moonraker {
    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F "moonraker-1.service")" ]; then
        echo "Moonraker service found! Stopping during Install."
        sudo systemctl stop moonraker-1
    else
        echo "Moonraker service not found, please install Moonraker first"
        exit 1
    fi
}

function link_extension {
    if [ -d "${MOONRAKER_TARGET_DIR}" ]; then
        echo "Linking extension to moonraker..."
        ln -sf "${SRCDIR}/component/timelapse.py" "${MOONRAKER_TARGET_DIR}/timelapse.py"
    else
        echo -e "ERROR: ${MOONRAKER_TARGET_DIR} not found."
        echo -e "Please Install moonraker first!\nExiting..."
        exit 1
    fi
    if [ -d "${KLIPPER_CONFIG_DIR}" ]; then
        echo "Linking macro file..."
        ln -sf "${SRCDIR}/klipper_macro/timelapse.cfg" "${KLIPPER_CONFIG_DIR}/timelapse.cfg"
    else
        echo -e "ERROR: ${KLIPPER_CONFIG_DIR} not found."
        echo -e "Try:\nUsage: ${0} -c /path/to/klipper_config\nExiting..."
        exit 1
    fi
}

function install_script {
# Create systemd service file
    SERVICE_FILE="${SYSTEMDDIR}/timelapse2.service"
    #[ -f $SERVICE_FILE ] && return
    if [ -f $SERVICE_FILE ]; then
        # Force remove
        sudo rm -f "$SERVICE_FILE"
    fi

    echo "Installing system start script..."
    sudo /bin/sh -c "cat > ${SERVICE_FILE}" << EOF
[Unit]
Description=Dummy Service for timelapse plugin
After=moonraker.service
Wants=moonraker.service
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c "sleep 1; echo 'Restarting Klipper and Moonraker...'"
ExecStopPost=systemctl restart klipper
ExecStopPost=systemctl restart moonraker
TimeoutStopSec=1s
[Install]
WantedBy=multi-user.target
EOF
# Use systemctl to enable the systemd service script
    sudo systemctl daemon-reload
    sudo systemctl enable timelapse.service
}


function restart_services {
    echo "Restarting Moonraker..."
    sudo systemctl restart moonraker-1
    echo "Restarting Klipper..."
    sudo systemctl restart klipper-1
}


function check_ffmpeg {

    if [ ! -f "$FFMPEG_BIN" ]; then
        echo -e "${YELLOW}WARNING:${NC} FFMPEG not found in '${FFMPEG_BIN}'. Render will not be possible!\nPlease install FFMPEG running:\n\n  sudo apt install ffmpeg\n\nor specify 'ffmpeg_binary_path' in moonraker.conf in the [timelapse] section if ffmpeg is installed in a different directory, to use render functionality"
	fi

}


### MAIN

# Parse command line arguments
while getopts "c:h" arg; do
    if [ -n "${arg}" ]; then
        case $arg in
            c)
                KLIPPER_CONFIG_DIR=$OPTARG
                break
            ;;
            [?]|h)
                echo -e "\nUsage: ${0} -c /path/to/klipper_config"
                exit 1
            ;;
        esac
    fi
    break
done

# Run steps
stop_klipper
stop_moonraker
link_extension
install_script
restart_services
check_ffmpeg

# If something checks status of install
exit 0
