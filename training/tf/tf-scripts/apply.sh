#!/bin/sh
set -o nounset
set -o errexit

. scripts/input.sh
scripts/prepare.sh
cd $PROVIDER

if [[ "$PROVIDER" == "az" ]]
then
	if ! az account show > /dev/null 2>&1
	then
		az login
	fi
fi

terraform apply
./display.sh
cd ..
