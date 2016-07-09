#!/bin/sh
cid=`docker-compose ps -q | awk '{ n=n+1; a=$0  } END{ if(n==1) { print a } }'`
if [[ -z "$cid" ]]
then
	echo "ERROR: no or too many running containers!"
fi
pid=`docker inspect --format "{{ .State.Pid }}" $cid`
sudo nsenter --target $pid --mount --uts --ipc --net --pid