#!/bin/bash
sudo kpackagetool6 -g -t Plasma/Applet -i ./package
sudo chmod +rwxrwxrwx -R /usr/share/plasma/plasmoids/at.lehklu.plasma.vrame6/*
