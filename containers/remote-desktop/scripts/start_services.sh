#!/bin/bash
nohup Xorg -dpi 96 -noreset -nolisten tcp +extension GLX +extension RANDR +extension RENDER -logfile ~desktop/.vnc/Xdummy-1.log -config ~/.vnc/xorg.conf :1 > /dev/null 2>&1 &
export DISPLAY=:1
nohup openbox-session > ~/.vnc/openbox.log 2>&1 &

# Reset xfce4 panel settings:
#     xfce4-panel --quit ; pkill xfconfd ; rm -rf ~/.config/xfce4/panel ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
# Find window properties:
#     xprop
#   and select window.
nohup xfce4-panel > /dev/null 2>&1 &
if [[ ! -d ~/.config/xfce4/panel ]]
then
	wnd=`comm -12 \
       <(xdotool search --name  'Panel'  | sort) \
       <(xdotool search --class 'Migrate'  | sort)`
    n=0
    while [[ -z "$wnd" ]]
    do
    	n=$((n+1))
    	if [[ $n -gt 10 ]]
    	then
    		break
    	fi
    	echo -n .
    	sleep 2
		wnd=`comm -12 \
    		<(xdotool search --name  'Panel'  | sort) \
       		<(xdotool search --class 'Migrate'  | sort)`
    done
    echo

    if [[ ! -z "$wnd" ]]
    then
    	echo "xfce4-panel config window found."
		xdotool windowactivate --sync $wnd
		xdotool key --window "$wnd" KP_Enter
	fi
fi

nohup gcolor2 > /dev/null 2>&1 &
nohup x11vnc -localhost -usepw -display :1 -geometry 1024x768 -forever -bg > ~desktop/.vnc/x11vnc.log 2>&1
websockify -D --web /home/desktop/noVNC/ 6080 127.0.0.1:5900