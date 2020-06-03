#!/bin/bash
stage="${1:?stage argument first}"; shift
HERE=$(unset CDPATH; cd $(dirname $0); pwd)
exec ssh ec2-user@$(cd $HERE && terraform output -json reg_public_dns | jq -r ".${stage}") psql.reg -c "\"COPY (select legal_name, public_first_name, public_last_name, email, contact_prefs, membership, member_number, key from members.people left join members.keys using (email) WHERE membership <> 'NonMember' and email NOT LIKE '%replace.me') TO STDOUT WITH CSV HEADER;\""
