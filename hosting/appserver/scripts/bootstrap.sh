#!/bin/bash

log() {
    prefix=$1; shift
    echo "### [$prefix] $*"
}

log python Installing dependencies
pip3 install --upgrade pip
pip3 install --upgrade pgcli psycopg2-binary keyrings.alt awscli

log app Preparing the user and DB directories
mkdir -p /opt/chicago/app /opt/chicago/init

log system Bring up docker
systemctl enable docker
systemctl start docker

