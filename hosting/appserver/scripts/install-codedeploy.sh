#!/bin/bash

log() {
    echo "### [codedeploy] $*"
}

# this whole mess is because of https://github.com/aws/aws-codedeploy-agent/issues/239#issuecomment-622630774

cd "$(mktemp -d)" || exit 1

log download codedeploy deb
wget https://${codedeploy_agent_s3_bucket}/releases/codedeploy-agent_1.0-1.1597_all.deb

log reconfigure the dependencies in the codedeploy deb
mkdir codedeploy-agent_1.0-1.1597_ubuntu20
dpkg-deb -R codedeploy-agent_1.0-1.1597_all.deb codedeploy-agent_1.0-1.1597_ubuntu20
sed 's/2.0/2.7/' -i ./codedeploy-agent_1.0-1.1597_ubuntu20/DEBIAN/control

log build rebuild the deb
dpkg-deb -b codedeploy-agent_1.0-1.1597_ubuntu20

log install codedeploy
dpkg -i codedeploy-agent_1.0-1.1597_ubuntu20.deb

log start the codedeploy service
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
