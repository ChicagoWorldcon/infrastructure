#!/bin/bash -eux
HERE=$(unset CDPATH; cd $(dirname $0); pwd)
hostname=${EC2_HOST:-$(cd $HERE && terraform output reg_public_dns)}
db_host=${DB_HOST:-$(cd $HERE && terraform output db_hostname)}
local_name=${1:-dump-$(date "+%Y-%m-%d-%H%M%S").sql}
temp_script=$(mktemp)
cleanup() {
    rm -vf $temp_script
}
trap cleanup EXIT
base=$(basename $temp_script)
cat << EOF > $temp_script
. /etc/chicago/db-env.sh
pg_dump -h $DB_HOST -U admin api > /tmp/${base}.sql
EOF

scp $temp_script ec2-user@$hostname:/tmp/$base.sh
ssh ec2-user@$hostname bash /tmp/$base.sh
scp ec2-user@$hostname:/tmp/$base.sql $local_name
ssh ec2-user@$hostname rm -vf /tmp/$base\*
