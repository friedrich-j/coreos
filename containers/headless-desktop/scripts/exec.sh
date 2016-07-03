#!/bin/bash
rm /home/desktop/display.env
dbus-daemon --system --fork
sudo -i -u desktop flock /var/run/xpra/.lock /usr/scripts/start_display.sh
if [[ -f "/etc/container_startup" ]]
then
	echo "invoking container_startup script ..."
	sudo -i -u desktop nohup sh -c '. ./display.env && . /etc/container_startup' > /tmp/startup.out 2>&1 &
fi
trap 'kill -s SIGTERM -1' SIGHUP SIGINT SIGTERM
tail -f /dev/null
echo "exiting ..."
wait
echo "done."
