#!/bin/sh
# Usage: build.sh <folder with the PKGBUILD>
# Builds the package and its .SRCINFO in a clean Arch system, as root. A
# source already in the folder is used as it is instead of being downloaded.
set -eu
folder=$(cd "$1" && pwd)

pacman -Syu --noconfirm --needed base-devel
# makepkg refuses to run as root. --nodeps leaves the dependencies out of this
# system, so check_install.sh shows that installing the package brings them.
id builder >/dev/null 2>&1 || useradd --create-home builder
chown -R builder "$folder"
cd "$folder"
runuser -u builder -- makepkg --nodeps --noconfirm
runuser -u builder -- makepkg --printsrcinfo >.SRCINFO
