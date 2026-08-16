#!/usr/bin/env bash
set -Eeuo pipefail

set_key() { dconf write "$1" "$2"; }
set_key /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
set_key /org/gnome/desktop/interface/clock-show-weekday true
set_key /org/gnome/desktop/interface/show-battery-percentage true
set_key /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,maximize,close'"
