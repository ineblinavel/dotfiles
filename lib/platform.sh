#!/usr/bin/env bash

detect_platform() {
  DISTRO_ID=unknown; DISTRO_VERSION=unknown; DISTRO_LIKE=""
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"; DISTRO_VERSION="${VERSION_ID:-unknown}"; DISTRO_LIKE="${ID_LIKE:-}"
  fi
  GNOME_MAJOR=""
  command_exists gnome-shell && GNOME_MAJOR="$(gnome-shell --version | sed -nE 's/.* ([0-9]+)(\..*)?$/\1/p')"
  SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
}

is_apt_family() { [[ "$DISTRO_ID" == debian || "$DISTRO_ID" == ubuntu || "$DISTRO_LIKE" == *debian* ]]; }
show_platform() { info "Sistema: $DISTRO_ID $DISTRO_VERSION; sessão: $SESSION_TYPE; GNOME: ${GNOME_MAJOR:-não detectado}"; }
