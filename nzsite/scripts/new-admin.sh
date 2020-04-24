#!/bin/bash -eu

name=$1; shift
email=$1; shift

echo "Enter an admin user password"
read -s password
echo

cat<<EOF | psql.reg
INSERT INTO admin.admins VALUES ('$email',  TRUE, TRUE, TRUE, TRUE, TRUE);
INSERT INTO members.keys VALUES ('$email', '$password');
INSERT INTO members.People (legal_name, email, membership, member_number, can_hugo_nominate, can_hugo_vote)
    VALUES ('$name', '$email', 'NonMember', NULL, false, false)
EOF

