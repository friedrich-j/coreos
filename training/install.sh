#!/bin/sh
TTY="/dev/`ps -o tty= -p $$`"
rm training.ignition coreos-install
wget -O coreos-install https://raw.github.com/coreos/init/master/bin/coreos-install || exit 1
wget -O training.ignition https://raw.githubusercontent.com/friedrich-j/coreos/master/training/training.ignition || exit 1
echo "Enter the password for user 'core'."
hash=`openssl passwd -1 < $TTY` || exit 1
awk -v h="$hash" '{ gsub("\\{PASSWORD\\}", h); print }' training.ignition > training2.ignition || exit 1
sudo coreos-install -d /dev/sda -i training2.ignition -o vmware_raw
