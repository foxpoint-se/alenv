#!/bin/bash
# List all SSM hybrid activations in the current AWS account
# Requires AWS CLI configured with appropriate permissions

aws ssm describe-activations \
  --query "ActivationList[*].[ActivationId,Description,ExpirationDate,RegistrationLimit,RegistrationsCount]" \
  --output table 