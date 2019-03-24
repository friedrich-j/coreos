#!/bin/sh
set -o nounset
set -o errexit

id="${TF_VAR_id:-training}"
pwd="training"

if [[ "$PROVIDER" == "aws" ]]
then
	region="eu-west-1"
else
	region="northeurope"
fi

function create_pwds {
	n=${TF_VAR_node_count:-1}
	echo "node_pwds = {"
	i=0
	while [[ "$i" -lt "$n" ]]
	do
		echo "  \"$i\" = \"`openssl passwd -1 "$pwd$i"`\""
		i=$((i+1))
	done
	echo "}"
}


function create_commons {
	cat << EOF
key_path="/home/user/terraform_data/id_$id.pub"
EOF
}

function create_ami {
	ami=`curl -sL https://coreos.com/dist/aws/aws-stable.json | jq --raw-output ".\"$region\".hvm"`
	cat << EOF
ami="$ami"
EOF
}

function convert_yaml {
	for i in `find ignition -name "*.yml.tpl" -or -name "*.yaml.tpl"`
	do
		j=`echo $i | sed 's/.ya\?ml./.ign./'`
		j="../terraform_tmp/`basename "$j"`"
		echo "--$i - $j"
		[[ "$i" == "$j" ]] && echo "hu?" && exit 1
		ct -in-file $i | sed -e 's/%23%23%23\(.*\)%23%23%23/${\1}/g' -e 's/###\(.*\)###/${\1}/g' > $j
	done
}

mkdir -p /home/user/terraform_tmp

convert_yaml

[[ -f "/home/user/terraform_data/id_$id" ]] || ssh-keygen -t rsa -b 4096 -C "$id" -N "$pwd" -f "/home/user/terraform_data/id_$id"

( create_commons ; create_ami ; create_pwds ) > /home/user/terraform_tmp/variables.auto.tfvars
