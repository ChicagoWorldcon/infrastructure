#!/usr/bin/env bash
set -euox pipefail

old_resource=$1
new_name=$2

old_name=$(terraform state show $old_resource | awk -F= '/name/ { print $2 }' | tr -d " \t\"")
old_secret=$(aws secretsmanager get-secret-value --secret-id $old_name | jq -r .SecretString)
aws secretsmanager create-secret --name $new_name
aws secretsmanager put-secret-value --secret-id $new_name --secret-string "$old_secret"
terraform state rm $old_resource
terraform import $old_resource $new_name





