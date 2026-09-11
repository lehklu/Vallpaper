#!/bin/sh

sudo kpackagetool6 -g -t Plasma/Applet -i ./package
sudo chmod a+rx -R /usr/share/plasma/plasmoids/at.lehklu.plasma.desktopindikator6/*