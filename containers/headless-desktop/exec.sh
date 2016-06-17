#!/bin/bash
echo "command: $1"
rm /home/desktop/desktop.env
dbus-daemon --system --fork
sudo -i -u desktop flock /var/run/xpra/.lock /scripts/start_display.sh xclock > /tmp/out.txt 2>&1
trap 'kill -s SIGTERM -1' SIGHUP SIGINT SIGTERM
tail -f /dev/null
echo "exiting ..."
wait
echo "done."
