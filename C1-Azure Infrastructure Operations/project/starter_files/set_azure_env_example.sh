#!/bin/bash
# run this script with source or .
# ARM_CLIENT_SECRET (service principal password) cannot be retrieved after creation but can be reset, see https://stackoverflow.com/a/62971780/4458566

echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
echo "Done"
