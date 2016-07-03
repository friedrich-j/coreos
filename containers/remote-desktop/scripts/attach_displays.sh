#!/bin/bash
`dirname "$0"`/clean_sockets.sh
for f in `ls -1 /var/run/xpra/display-*`
do
	echo "attaching to display $f ..."
	xpra attach --opengl=no unix:$f
done
