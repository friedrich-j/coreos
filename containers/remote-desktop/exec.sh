#!/bin/bash
if [[ -f /home/desktop/.ssh/authorized_keys ]]
then
	nuid=`stat -c %u /home/desktop/.ssh/authorized_keys`
	[[ `id -u` -ne $nuid ]] && echo changing uid of user 'desktop' to $nuid ... && usermod -u $nuid desktop
fi
rm /home/desktop/desktop.env
sudo -i -u desktop flock /var/run/xpra/.lock /scripts/clean_sockets.sh
sudo -i -u desktop flock /var/run/xpra/.lock /scripts/start_display.sh
dbus-daemon --system --fork
rm /tmp/.X1-lock /tmp/.X11-unix/X1
sudo -i -u desktop vncserver :1 -geometry 1280x800 -depth 24 -localhost
/usr/sbin/sshd -D

