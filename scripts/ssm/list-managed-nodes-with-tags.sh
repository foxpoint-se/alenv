#!/bin/bash
# List all SSM managed nodes with their tags
# Requires AWS CLI configured with appropriate permissions

INSTANCES=$(aws ssm describe-instance-information --query "InstanceInformationList[*].[InstanceId,ComputerName,PlatformType,PlatformName,PingStatus]" --output json)

COUNT=$(echo "$INSTANCES" | jq 'length')

for ((i=0; i<$COUNT; i++)); do
  INSTANCE_ID=$(echo "$INSTANCES" | jq -r ".[$i][0]")
  COMPUTER_NAME=$(echo "$INSTANCES" | jq -r ".[$i][1]")
  PLATFORM_TYPE=$(echo "$INSTANCES" | jq -r ".[$i][2]")
  PLATFORM_NAME=$(echo "$INSTANCES" | jq -r ".[$i][3]")
  PING_STATUS=$(echo "$INSTANCES" | jq -r ".[$i][4]")

  echo "InstanceId: $INSTANCE_ID"
  echo "  ComputerName: $COMPUTER_NAME"
  echo "  PlatformType: $PLATFORM_TYPE"
  echo "  PlatformName: $PLATFORM_NAME"
  echo "  PingStatus: $PING_STATUS"

  TAGS=$(aws ssm list-tags-for-resource --resource-type ManagedInstance --resource-id "$INSTANCE_ID" --query "TagList" --output json)
  if [[ "$TAGS" != "[]" ]]; then
    echo "  Tags:"
    echo "$TAGS" | jq -r '.[] | "    "+.Key+": "+.Value'
  else
    echo "  Tags: (none)"
  fi
  echo "---"
done 