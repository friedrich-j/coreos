#!/bin/sh
a1=`df -l --output=avail --total | tail -n 1`
docker ps --all -f status=exited --format '{{.CreatedAt}};{{.ID}};{{.Image}}' | sort -r | awk -F';' 'a[$3] || match($3, /[a-f0-9]{12}/) { b[$3]="x"; print $2 } !b[$3]{ a[$3]="x" }' | xargs --no-run-if-empty docker rm
docker rmi $(docker images -qf "dangling=true")
a2=`df -l --output=avail --total | tail -n 1`
echo
echo "free'd disk space: $(((a2-a1)/1000)) MB"
