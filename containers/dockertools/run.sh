#!/bin/sh
mkdir tmp
docker run --rm -it -v "$PWD/tmp":/data friedrich-j/dockertools $*