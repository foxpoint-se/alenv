#!/bin/bash
# Register the SSM agent on this machine using an activation code and ID
# Usage:
#   ./register-ssm-agent.sh [--code ACTIVATION_CODE] [--id ACTIVATION_ID] [--region REGION]
#
# If arguments are not provided, the script will prompt for them.

set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --code)
      ACTIVATION_CODE="$2"
      shift 2
      ;;
    --id)
      ACTIVATION_ID="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Prompt for missing values
if [[ -z "$ACTIVATION_CODE" ]]; then
  read -p "Enter Activation Code: " ACTIVATION_CODE
fi
if [[ -z "$ACTIVATION_ID" ]]; then
  read -p "Enter Activation ID: " ACTIVATION_ID
fi
if [[ -z "$REGION" ]]; then
  read -p "Enter AWS Region (e.g. eu-west-1): " REGION
fi

# Print summary and ask for confirmation
cat <<EOF
About to register this machine as an SSM managed instance with:
  Activation Code: $ACTIVATION_CODE
  Activation ID:   $ACTIVATION_ID
  Region:          $REGION
EOF
read -p "Do you want to continue? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted. No registration performed."
  exit 0
fi

# Register the agent
sudo amazon-ssm-agent -register -code "$ACTIVATION_CODE" -id "$ACTIVATION_ID" -region "$REGION"

# Show registration file
echo "\nRegistration file (/var/lib/amazon/ssm/registration):"
sudo cat /var/lib/amazon/ssm/registration

echo "\nSSM agent registration complete." 