#!/bin/sh
wget -q -O coreos-install https://raw.github.com/coreos/init/master/bin/coreos-install || exit 1
wget -q -O training.ignition https://raw.githubusercontent.com/friedrich-j/coreos/master/containers/training/training.ignition || exit 1
echo "Enter the password for user 'core'."
hash=`openssl passwd -1` || exit 1
awk -v h="$hash" '{ gsub("\\{PASSWORD\\}", h); print }' training.ignition > training2.ignition || exit 1
coreos-install -d /dev/sda -i training2.ignition -o vmware_raw
