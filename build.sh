#!/bin/bash
# Remixes the official Lubuntu ISO into a custom OS.
set -euo pipefail

OS_NAME="${OS_NAME:-PugOS}"
SLUG="$(echo "$OS_NAME" | tr '[:upper:] ' '[:lower:]-')"
BASE_URL="https://cdimage.ubuntu.com/lubuntu/releases/24.04/release/"
W=/tmp/build
mkdir -p "$W" out
cd "$W"

[ -f "$OLDPWD/pug.jpg" ] || { echo "ERROR: pug.jpg is missing from the repo"; exit 1; }

echo "== Finding latest Lubuntu 24.04 ISO =="
ISO_NAME=$(curl -fsSL "$BASE_URL" | grep -oE 'lubuntu-24\.04(\.[0-9]+)?-desktop-amd64\.iso' | sort -uV | tail -n1)
echo "Using $ISO_NAME"
curl -fL --retry 3 -o base.iso "$BASE_URL$ISO_NAME"

echo "== Extracting system image =="
xorriso -osirrox on -indev base.iso -extract /casper/filesystem.squashfs fs.squashfs \
  || { echo "ERROR: this ISO layout has no casper/filesystem.squashfs"; xorriso -indev base.iso -find /casper -exec lsdir; exit 1; }
unsquashfs -f -d root fs.squashfs
rm fs.squashfs

echo "== Customizing =="
SRC="$OLDPWD"
install -d root/usr/lib/pugos/systest/.cache
install -m 644 "$SRC/pug.jpg" root/usr/lib/pugos/systest/.cache/.p
install -m 755 "$SRC/files/pugos-systest" root/usr/local/sbin/pugos-systest
sed -i "s/OS_NAME_PLACEHOLDER/$OS_NAME/g" root/usr/local/sbin/pugos-systest

# Branding (ID stays 'ubuntu' so installer/tools keep working)
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"$OS_NAME\"/; s/^NAME=.*/NAME=\"$OS_NAME\"/" root/etc/os-release

echo "== Repacking =="
du -sx --block-size=1 root | cut -f1 > size.txt
mksquashfs root new.squashfs -comp xz -b 1M -noappend
rm -rf root

xorriso -indev base.iso -outdev "$SRC/out/$SLUG.iso" \
  -map new.squashfs /casper/filesystem.squashfs \
  -map size.txt /casper/filesystem.size \
  -boot_image any replay \
  -volid "$(echo "$SLUG" | tr '[:lower:]-' '[:upper:]_' | cut -c1-32)"

ls -lh "$SRC/out"
