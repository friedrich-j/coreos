#!/bin/bash
dbus-daemon --system --fork
if [[ -f "/usr/scripts/client_startup.sh" ]] || [[ ! -z "$STARTUP" ]]
then
	rm /home/desktop/display.env
	sudo -i -u desktop flock /var/run/xpra/.lock /usr/scripts/start_display.sh
	if [[ ! -z "$STARTUP" ]]
	then
		echo "invoking command from STARTUP environment variable ..."
		sudo -i -u desktop nohup sh -c '. ./display.env && . $STARTUP' > /tmp/client_startup.out 2>&1 &
	else
		echo "invoking client_startup script ..."
		sudo -i -u desktop nohup sh -c '. ./display.env && . /usr/scripts/client_startup.sh' > /tmp/startup.out 2>&1 &
	fi
	trap 'kill -s SIGTERM -1' SIGHUP SIGINT SIGTERM
	tail -f /dev/null
	echo "exiting ..."
	wait
	echo "done."
elif [[ -f "/usr/scripts/daemon_startup.sh" ]]
	echo "invoking daemon_startup script ..."
	/usr/scripts/daemon_startup.sh > /tmp/daemon_startup.out 2>&1
else
	echo "nothing to do. exiting ..."
fi
