#!/usr/bin/env bash

set -euo pipefail

if [ "$EUID" != 0 ]; then
  echo "Run as root"
  exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

do_unmount=0
mounted_disk=""
if [ ! -f ./srv/imgmount/md5sum.txt ]; then
  echo "mounting ISO"
  devs=$(hdiutil attach -nomount srv/images/ubuntu-22.04.2-live-server-amd64.iso)
  mounted_disk=$(echo "${devs}" | head -n1 | cut -f1 | tr -d '[:blank:]')
  mount -t cd9660 ${mounted_disk}s1 srv/imgmount
  do_unmount=1
fi

if [ ! -f ./srv/imgmount/md5sum.txt ]; then
  echo "Couldn't mount image, bailing out"
  exit 1
fi

echo "setting srv and plist permissions"
chmod -R a+rX ./srv
tftpown=$(stat -f '%u' tftp.plist)
tftpgrp=$(stat -f '%g' tftp.plist)
chown root:wheel tftp.plist
chmod 744 tftp.plist

echo "launching tftp"
launchctl load -F tftp.plist
echo "launching http"
python3 -m http.server -b 0.0.0.0 -d ./srv &
server=$!

echo "tftp and http servers running... Press any enter to quit"
read -s

echo "stopping http"
kill $server
echo "stopping tftp"
launchctl unload -F tftp.plist
echo "resetting plist permissions"
chown ${tftpown}:${tftpgrp} tftp.plist

if [ $do_unmount -eq 1 ]; then
  echo "unmounting ISO"
  umount srv/imgmount
  hdiutil detach $mounted_disk
fi
