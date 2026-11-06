#!/bin/bash
# Install the driver via DKMS: rebuilt automatically for every new kernel,
# and auto-loaded by udev whenever the EIE Pro is plugged in (also at boot).
# Does NOT unload/reload the currently running driver.
set -e
cd "$(dirname "$0")"
VER=1.1
SRC=/usr/src/akai-eie-pro-$VER

sudo -v
dpkg -s dkms >/dev/null 2>&1 || sudo apt install -y dkms
if dkms status akai-eie-pro/$VER | grep -q .; then
    sudo dkms remove akai-eie-pro/$VER --all
fi
sudo rm -rf "$SRC"
sudo mkdir -p "$SRC"
sudo cp akai_eie_pro.c Makefile dkms.conf "$SRC/"
sudo dkms install akai-eie-pro/$VER
echo "---"
dkms status akai-eie-pro
modinfo -n akai_eie_pro
echo "installed srcversion: $(modinfo -F srcversion akai_eie_pro)"
echo "running   srcversion: $(cat /sys/module/akai_eie_pro/srcversion 2>/dev/null || echo not-loaded)"
