#!/bin/sh
set -o nounset
set -o errexit

read -p "Provider? [AWS,az] " PROVIDER
[[ -z "$PROVIDER" ]] && PROVIDER="aws"

read -p "ID? [training] " TF_VAR_id
[[ -z "$TF_VAR_id" ]] && TF_VAR_id="training"

[[ -z "${rg-}" ]] && TF_VAR_rg="rg_$TF_VAR_id" || TF_VAR_rg="$rg"

if [[ -z "${1:-}" ]]
then
	read -p "Node count? [1] " TF_VAR_node_count
	[[ -z "$TF_VAR_node_count" ]] && TF_VAR_node_count=1
fi

export TF_VAR_id TF_VAR_rg TF_VAR_node_count PROVIDER
export TF_CLI_ARGS="-state=/home/user/terraform_data/terraform_${PROVIDER}_$TF_VAR_id.tfstate -var-file=/home/user/terraform_tmp/variables.auto.tfvars"
