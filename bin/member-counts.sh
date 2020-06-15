#!/bin/bash
set -ue
stage="${1:?stage argument first}"; shift
ssh reg-${stage} psql.reg -c "\"SELECT membership, COUNT(*) FROM members.people WHERE membership <> 'NonMember' GROUP BY membership;\""
