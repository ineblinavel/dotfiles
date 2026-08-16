#!/usr/bin/env bash
set -Eeuo pipefail
dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click true
dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'suspend'"
