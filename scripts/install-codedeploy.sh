#!/bin/bash
sudo yum -y update
sudo yum install -y ruby wget
cd $HOME
wget ${codedeploy_agent_s3_bucket}/latest/install
chmod +x ./install
sudo ./install auto
