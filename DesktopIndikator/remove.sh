#!/bin/sh
set -eu

PLUGIN_ID="at.lehklu.plasma.desktopindikator6"

sudo kpackagetool6 -g -t Plasma/Applet --remove "$PLUGIN_ID"