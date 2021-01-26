#!/bin/bash

log() {
    echo "### [codedeploy] $*"
}

# this whole mess is because of https://github.com/aws/aws-codedeploy-agent/issues/239#issuecomment-622630774

cd "$(mktemp -d)" || exit 1

wget https://${codedeploy_agent_s3_bucket}/latest/install
chmod +x install
./install auto | tee ./install-log

log start the codedeploy service
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
