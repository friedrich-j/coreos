#!/bin/sh
TTY="/dev/`ps -o tty= -p $$`"
rm *.ign coreos-install
read -p "ignition path? " ign_uri < $TTY || exit 1
ign=`basename "$ign_uri"`
wget -O coreos-install https://raw.github.com/coreos/init/master/bin/coreos-install || exit 1
wget -O "$ign" https://raw.githubusercontent.com/friedrich-j/coreos/master/ignition/$ign_uri || exit 1
echo "Enter the password for user 'core'."
hash=`openssl passwd -1 < $TTY` || exit 1
chmod 755 coreos-install
sed -i "s|PASSWORD|$hash|" "$ign"
sudo $PWD/coreos-install -d /dev/sda -i "$ign" -o vmware_raw
