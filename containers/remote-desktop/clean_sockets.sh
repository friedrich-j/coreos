#!/bin/bash
cd /var/run/xpra
for f in `ls -1 display-*`
do
	echo "" | socat - UNIX-CONNECT:$f
	if [[ $? -ne 0 ]]
	then
		display=`echo $f | sed -E 's/^.*-([0-9]+)\$/\\1/'`
		echo "deleting orphaned display :$display ..."
		rm *:$display.log *:$display.desc $f
	fi
done
