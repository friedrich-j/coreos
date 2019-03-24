#!/bin/sh
set -o nounset
set -o errexit

aws ec2 describe-instances --region ${TF_VAR_region:-eu-west-1} | jq --arg scope ${TF_VAR_id:-training} '.Reservations[].Instances[] | select(.Tags[] | .Key=="Scope" and .Value == $scope) | select(.State.Name == "running") | [ (.Tags[] | select(.Key=="Name") | .Value ), (.PublicIpAddress), (.PublicDnsName) ] | @tsv' | sort | awk 'BEGIN{ print "ID^IP^DNS"  } { s=substr($0, 2, length($0)-2); gsub(/\\t/, "^", s); print s }' | column -t -s^ | awk 'BEGIN { i=0; m=0 } { a[i]=$0; i=i+1; n=length($0); if(n>m) { m=n } } END{ print a[0]; print gensub(/ /, "=", "g", sprintf("%" m "s", "")); for (j=1;j<i;j++) { print a[j] } }'


