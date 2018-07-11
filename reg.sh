#!/bin/bash
exec ssh ec2-user@$(terraform output reg_public_dns) "$@"
