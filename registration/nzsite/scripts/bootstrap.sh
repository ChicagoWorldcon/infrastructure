#!/bin/bash

log() {
    prefix=$1; shift
    echo "### [$prefix] $*"
}

log user Adding the docker group to the default user
usermod -a -G docker ubuntu

log python Installing dependencies
pip3 install pgcli psycopg2-binary keyrings.alt

log app Preparing the user and DB directories
mkdir -p /postgres/init.d/${db_superuser_username}
mkdir -p /postgres/init.d/site
mkdir -p /opt/chicago/app /opt/chicago/init

log app Set ownership on the app directories
chown -R ubuntu /postgres/init.d /opt/chicago
chmod -R u+Xrw,g-rwx,o-rwx /opt/chicago

log system Bring up docker
systemctl enable docker
systemctl start docker


log app Initial credential sync
sudo -u ubuntu /opt/chicago/bin/rotate-creds.sh
