#!/bin/bash

log() {
    prefix=$1; shift
    echo "### [$prefix] $*"
}

log python Installing dependencies
pip3 install pgcli psycopg2-binary keyrings.alt

log app Preparing the user and DB directories
mkdir -p /opt/chicago/app /opt/chicago/init

log system Bring up docker
systemctl enable docker
systemctl start docker

