#!/usr/bin/env bash
set -euo pipefail

kernel_name="$(uname -s)"
case "${kernel_name}" in
  Linux*)  machine=Linux ;;
  Darwin*) machine=Mac ;;
  *) machine=UNKNOWN
esac

if [ "$machine" = "UNKNOWN" ]; then
  echo "Unknow System: $kernel_name, exiting..."
  exit 1
fi

if [ "$machine" = "Linux" ]; then
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    linux_os="${ID:-unknown}"
  else
    linux_os="unknown"
  fi

  if [ "$linux_os" = "unknown" ]; then
    echo "Unknow Linux Operate System, exiting..."
    exit 1
  fi
else
  linux_os="none"
fi

src="$HOME/flake"

if [ "$linux_os" = "nixos" ]; then
    dst="/etc/nixos"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
	sudo rm -f "$dst.bak"
        sudo mv "$dst" "$dst.bak"
    else
        sudo rm -f "$dst"
    fi

    sudo ln -sfn "$src" "$dst"
else
    dst="$HOME/.config/home-manager"
    mkdir -p "$(dirname "$dst")"
    rm -rf "$dst"
    ln -sfn "$src" "$dst"
fi

echo "generated soft link: $dst -> $src"
