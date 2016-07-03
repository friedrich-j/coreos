#!/bin/bash
if [[ ! -f ~/display.env ]]
then
	display=`ls -1 /var/run/xpra/* 2>/dev/null | sed -E -e '/:/d' -e 's/^.*-([0-9]+)$/\1/' | sort -r | head -n 1`
	if [[ -z "$display" ]]
	then
		display=100
	else
		display=$((display+1))
	fi
	echo starting display :$display ...
	xpra start :$display
	export DISPLAY=:$display
	echo "export DISPLAY=:$display" > ~/display.env
	touch /var/run/xpra/"$CONTAINER_LABEL-$HOSTNAME:$display.desc"
	while [[ ! -S /var/run/xpra/display-$display ]]
	do
		echo "waiting ..."
		sleep 1
	done
else
	. ~/display.env
fi
