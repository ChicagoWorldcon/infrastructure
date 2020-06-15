#!/bin/bash
set -ue
stage="${1:?stage argument first}"; shift
script_file=$(mktemp)
dest_script_file=$(ssh ec2-user@reg-${stage} mktemp)
cat<<EOF>$script_file
COPY (
  select legal_name,
         CASE
         WHEN public_first_name IS NOT NULL THEN 't'
         ELSE NULL
         END as make_public,
         public_first_name,
         public_last_name,
         badge_text,
         email,
         contact_prefs,
         membership,
         member_number,
         key
    FROM members.people
           LEFT JOIN members.keys USING (email)
   WHERE membership <> 'NonMember'
     AND email NOT LIKE '%replace.me'
) TO STDOUT WITH CSV HEADER;
EOF

scp $script_file reg-${stage}:$dest_script_file
ssh reg-${stage} psql.reg -f $dest_script_file 
