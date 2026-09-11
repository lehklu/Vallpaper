#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package"
PLUGIN_ID="at.lehklu.plasma.desktopindikator6"
INSTALL_DIR="/usr/share/plasma/plasmoids/$PLUGIN_ID"

sudo kpackagetool6 -g -t Plasma/Applet -i "$PACKAGE_DIR"
if [ -d "$INSTALL_DIR" ]; then
    sudo chmod -R a+rx "$INSTALL_DIR"
fi