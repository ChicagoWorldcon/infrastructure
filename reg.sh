#!/bin/bash
bastion_ip=$(terraform output bastion_public_ip)
registration_ip=$(terraform output reg_private_ip)
#exec ssh -oProxyCommand="ssh ec2-user@${bastion_ip} -W %h:%p" ec2-user@${registration_ip}
#exec ssh -A -J ec2-user@${bastion_ip} ec2-user@${registration_ip}
ssh ec2-user@$(terraform output reg_public_dns)
