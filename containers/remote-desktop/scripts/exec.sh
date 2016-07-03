#!/bin/bash
if [[ -f /home/desktop/.ssh/authorized_keys ]]
then
	nuid=`stat -c %u /home/desktop/.ssh/authorized_keys`
	[[ `id -u` -ne $nuid ]] && echo changing uid of user 'desktop' to $nuid ... && usermod -u $nuid desktop
fi
rm /home/desktop/display.env
sudo -i -u desktop flock -w 15 /var/run/xpra/.lock /scripts/clean_sockets.sh
if [[ $? -ne 0 ]]
then
	echo "ERROR: could not obtain lock !"
	exit 1
fi
dbus-daemon --system --fork
rm /tmp/.X1-lock /tmp/.X11-unix/X1
sudo -i -u desktop nohup Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER -logfile ~desktop/.vnc/Xdummy-1.log -config ~desktop/.vnc/xorg.conf :1 > /dev/null 2>&1 &
sudo -i -u desktop sh -c "DISPLAY=:1 nohup openbox-session > ~/.vnc/openbox.log 2>&1 &"
sudo -i -u desktop sh -c "DISPLAY=:1 nohup gcolor2 > /dev/null 2>&1 &"
sudo -i -u desktop nohup x11vnc -localhost -usepw -display :1 -geometry 1024x768 -forever -bg > ~desktop/.vnc/x11vnc.log 2>&1
sudo -i -u desktop websockify -D --web /home/desktop/noVNC/ 6080 127.0.0.1:5901
/usr/sbin/sshd -D






#apt-get --reinstall install xfonts-base

#nohup Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER -logfile ${HOME}/.vnc/Xdummy-1.log -config ${HOME}/xorg.conf :5 > /dev/null 2>&1 &

