#!/bin/bash
sudo yum -y update
sudo yum install -y ruby wget
cd $HOME
wget aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
