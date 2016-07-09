#!/bin/bash

function build 
{
	local img=$1
	local dir=`echo "$img" | awk -v d="$base_dir" -v o="$owner" '{ n=split($0, a, "/"); b=a[n]; gsub(/:latest$/, "", b); gsub(/-/, "/", b); gsub(/:/, "/#", b) } END{ if(o==a[1]) { print d "/" b } }'`
	
	echo
	echo "=== fetching $img ====================================="
	
	if [[ -z "$dir" ]]
	then
		docker pull "$img"
		return $?
	fi
	
	if [[ ! -d "$dir" ]]
	then
		cd "$base_dir"
		git pull
		if [[ ! -d "$dir" ]]
		then
			echo "ERROR: invalid directory '$dir'!"
			return 1
		fi
		cd "$dir"
	else
		cd "$dir"
		git pull
	fi
	
	local pimg=`awk '/^FROM / { a=substr($0, 5); gsub(/[ \t]+$/, "", a); gsub(/^[ \t]+/, "", a); print a }' Dockerfile`

	if ! build "$pimg"
	then
		return $?
	fi
	
	echo
	echo "=== building $img ====================================="
	
	cd "$dir"
	docker-compose build
	return $?
}

currdir="$PWD"
img=`awk '/^FROM / { a=substr($0, 5); gsub(/[ \t]+$/, "", a); gsub(/^[ \t]+/, "", a); print a }' Dockerfile`
echo "parent image: $img"

a=`cat docker-compose.yml | awk 'function value(a) { gsub(/^ *[^:]+: */, "", a); gsub(/[ \t]+$/, "", a); gsub(/^[ \t]+/, "", a); return a } /^ *build:/ { b=value($0) } /^ *image:/ { i=value($0) } END{ gsub("^.$", "", b); gsub("^./", "", b); gsub(/:latest$/, "", i); n=split(i, a, "/"); u=a[1]; i=a[2]; gsub("^" b "-", "", i); gsub(/[^-:]+/, "..", i); gsub(/[-:]/, "/", i); print "owner=" u ";base_dir=\`cd " i "; echo $PWD\`" }'`
eval $a
echo "owner: $owner"
echo "base directory: $base_dir"

build "$img"

echo
echo "=== building current image ====================================="
cd "$currdir"
docker-compose build