#!/bin/bash
# Create a new AWS SSM hybrid activation via AWS CLI
# Usage:
#   ./create-activation.sh --name NAME --default-instance-name DEFAULT_INSTANCE_NAME [--role ROLE] [--limit LIMIT] [--expires YYYY-MM-DDTHH:MM:SS]
#
# NAME and DEFAULT_INSTANCE_NAME are required.
# Defaults:
#   ROLE: service-role/AmazonEC2RunCommandRoleForManagedInstances
#   LIMIT: 10
#   EXPIRES: 30 days from today (max allowed)
#
# Example:
#   ./create-activation.sh --name rpi-activation --default-instance-name rpi --role MySSMRole --limit 20 --expires 2030-01-01T00:00:00

set -e

# Defaults
ROLE="service-role/AmazonEC2RunCommandRoleForManagedInstances"
LIMIT=10
EXPIRES=$(date -d "+30 days" +%Y-%m-%dT00:00:00)
NAME=""
DEFAULT_INSTANCE_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      NAME="$2"
      shift 2
      ;;
    --default-instance-name)
      DEFAULT_INSTANCE_NAME="$2"
      shift 2
      ;;
    --role)
      ROLE="$2"
      shift 2
      ;;
    --limit)
      LIMIT="$2"
      shift 2
      ;;
    --expires)
      EXPIRES="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "Error: --name argument is required."
  exit 1
fi
if [[ -z "$DEFAULT_INSTANCE_NAME" ]]; then
  echo "Error: --default-instance-name argument is required."
  exit 1
fi

# Check if activation with the same name already exists
EXISTING=$(aws ssm describe-activations --query "ActivationList[?Description=='$NAME']" --output json)
if [[ "$EXISTING" != "[]" ]]; then
  echo "Error: An activation with the name '$NAME' already exists."
  exit 1
fi

# Print summary and ask for confirmation
cat <<EOF
About to create a new SSM hybrid activation with the following parameters:
  Name:                $NAME
  DefaultInstanceName: $DEFAULT_INSTANCE_NAME
  Role:                $ROLE
  Limit:               $LIMIT
  Expires:             $EXPIRES
EOF
read -p "Do you want to continue? [y/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted. No activation created."
  exit 0
fi

# Create activation
RESULT=$(aws ssm create-activation \
  --default-instance-name "$DEFAULT_INSTANCE_NAME" \
  --iam-role "$ROLE" \
  --registration-limit "$LIMIT" \
  --expiration-date "$EXPIRES" \
  --description "$NAME" \
  --output json)

ACTIVATION_ID=$(echo "$RESULT" | jq -r .ActivationId)
ACTIVATION_CODE=$(echo "$RESULT" | jq -r .ActivationCode)

if [[ -n "$ACTIVATION_ID" && -n "$ACTIVATION_CODE" ]]; then
  echo "Activation created!"
  echo "  ActivationId:   $ACTIVATION_ID"
  echo "  ActivationCode: $ACTIVATION_CODE"
  echo "  Name:           $NAME"
  echo "  DefaultInstanceName: $DEFAULT_INSTANCE_NAME"
  echo "  Role:           $ROLE"
  echo "  Limit:          $LIMIT"
  echo "  Expires:        $EXPIRES"
else
  echo "Failed to create activation."
  exit 1
fi 