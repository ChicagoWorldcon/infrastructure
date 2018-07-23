#!/bin/bash
HERE=$(unset CDPATH; cd $(dirname $0); pwd)
exec ssh ec2-user@$(cd $HERE && terraform output reg_public_dns) "$@"
