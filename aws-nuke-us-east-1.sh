#!/bin/bash
set -e

REGIONS=("us-east-1" "us-east-2")

echo "⚠️ WARNING: This script will DELETE resources in regions: ${REGIONS[*]}"

if [[ -z "$CI" ]]; then
  read -p "Type 'yes' to proceed: " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 1
  fi
else
  echo "CI environment detected, skipping prompt."
fi

for REGION in "${REGIONS[@]}"; do
  echo "🧹 Starting AWS cleanup in $REGION..."

  # Delete Lambda Functions
  for fn in $(aws lambda list-functions --region $REGION --query 'Functions[*].FunctionName' --output text); do
    echo "Deleting Lambda: $fn"
    aws lambda delete-function --function-name "$fn" --region $REGION
  done

  # Delete S3 Buckets
  for bucket in $(aws s3api list-buckets --query 'Buckets[*].Name' --output text); do
    region=$(aws s3api get-bucket-location --bucket $bucket --query 'LocationConstraint' --output text)
    [[ "$region" == "None" ]] && region="us-east-1"
    if [[ "$region" == "$REGION" ]]; then
      echo "Emptying and deleting S3 Bucket: $bucket"
      aws s3 rm "s3://$bucket" --recursive || true
      aws s3api delete-bucket --bucket "$bucket" --region $REGION || true
    fi
  done

  # Delete DynamoDB Tables
  for table in $(aws dynamodb list-tables --region $REGION --query 'TableNames[*]' --output text); do
    echo "Deleting DynamoDB table: $table"
    aws dynamodb delete-table --table-name "$table" --region $REGION
  done

  # Delete EventBridge Rules
  for rule in $(aws events list-rules --region $REGION --query 'Rules[*].Name' --output text); do
    echo "Deleting EventBridge rule: $rule"
    aws events remove-targets --rule "$rule" --ids 1 --region $REGION || true
    aws events delete-rule --name "$rule" --region $REGION
  done

  # Delete IAM Roles (filtered for lambda_exec)
  for role in $(aws iam list-roles --query 'Roles[*].RoleName' --output text); do
    if [[ "$role" == *lambda_exec* ]]; then
      echo "Detaching and deleting IAM role: $role"
      for policy in $(aws iam list-attached-role-policies --role-name "$role" --query 'AttachedPolicies[*].PolicyArn' --output text); do
        aws iam detach-role-policy --role-name "$role" --policy-arn "$policy"
      done
      aws iam delete-role --role-name "$role"
    fi
  done

  echo "✅ Cleanup complete in $REGION"
done
