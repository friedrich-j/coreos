#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [[ $# -ne 1 ]]
then
	printf "${RED}ERROR:${NC} invalid number arguments!\n"
	exit 1
fi

declare -A images containers container_sizes container_cmds

a=`docker images --no-trunc --format '{{.ID}};{{.Repository}};{{.Tag}}' | awk -F';' '{ if($2=="<none>") { a = $1 } else { a = $2 ":" $3 }; print "images[" $1 "]=\"" a "\"" }'`
eval $a
IFS=$'\n'
for i in "${!images[@]}"
do
	for j in `docker history --human=false --no-trunc $i | tail -n+2 | grep -v missing | awk '{ print "a=" $1 " b=" $NF }'`
	do
	    eval $j
	    
	    c=`docker history --human=false --no-trunc friedrich-j/remote-desktop | grep -e "^$a" | awk '{ match ($0, "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z +"); print substr($0, RSTART+RLENGTH,60) }'`
	    
	    container_cmds[$a]="$c"
	    container_sizes[$a]=$b
	    containers[$a]="${containers[$a]};$i"
	done
	
done
IFS=$'\n'
n=0
m=0
for i in `docker history --no-trunc -q "$1" | grep -v missing`
do
	if echo "${containers[$i]}" | grep -E "^;?([^;]+;[^;]+)" > /dev/null
	then
		printf "${GREEN}"
		n=$((n+container_sizes[$i]))
	else
		printf "${YELLOW}"
		m=$((m+container_sizes[$i]))
	fi
	echo "$i        $((container_sizes[$i]/1000/1000)) MB"
	echo "      ${container_cmds[$i]}"
	IFS=$';'
	for j in ${containers[$i]}
	do
		if [[ ! -z "$j" ]]
		then
			if [[ ! -z "${images[$j]}" ]]
			then
				echo "  --> ${images[$j]}"
			else
				echo "  --> $j"
			fi
		fi
	done
done
echo
printf "${YELLOW}Total: $((m/1000/1000)) MB\n"
printf "${GREEN}Total: $((n/1000/1000)) MB\n"
printf "${NC}Total: $(((m+n)/1000/1000)) MB\n"
