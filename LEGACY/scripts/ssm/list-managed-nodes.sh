#!/bin/bash
# List all SSM managed nodes (hybrid/on-premises and EC2) in the current AWS account
# Requires AWS CLI configured with appropriate permissions

aws ssm describe-instance-information \
  --query "InstanceInformationList[*].[InstanceId,ComputerName,PlatformType,PlatformName,PingStatus]" \
  --output table 