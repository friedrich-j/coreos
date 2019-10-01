#!/bin/sh
set -o nounset
set -o errexit

[[ -z "${rg-}" ]] && rg="rg_${TF_VAR_id:-training}"

az vm list-ip-addresses | jq --arg rg "$rg" '.[].virtualMachine | select(.resourceGroup==$rg) | [ .name, .network.publicIpAddresses[].ipAddress ] | @tsv' | sort | awk 'BEGIN{ print "ID^IP"  } { s=substr($0, 2, length($0)-2); gsub(/\\t/, "^", s); print s }' | column -t -s^ | awk 'BEGIN { i=0; m=0 } { a[i]=$0; i=i+1; n=length($0); if(n>m) { m=n } } END{ print a[0]; print gensub(/ /, "=", "g", sprintf("%" m "s", "")); for (j=1;j<i;j++) { print a[j] } }'
