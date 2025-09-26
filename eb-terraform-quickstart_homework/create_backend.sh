#!/bin/bash
# This script will create the cloud formation stack for you, make sure
# you tag it correctly or you are at a risk of administrators deleting
# it wihtout further notice

user=gustavosoyoy
repo=thisisanotherepojusttotest
stack=$repo-$user

echo $stack

aws cloudformation deploy \
    --stack-name "$stack" \
    --template-file ./backend.yaml \
    --parameter-overrides BucketName="$stack"-terraform-state \
    --tags Topic=Terraform Owner="$user"

s3_bucket=$(aws cloudformation describe-stacks \
    --stack "$stack" --output text \
    --query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" 
)
kms_key_id=$(aws cloudformation list-stack-resources \
  --stack-name "$stack" \
  --query "StackResourceSummaries[?ResourceType=='AWS::KMS::Key'].PhysicalResourceId" \
  --output text
)

echo
echo "S3 Bucket : ${s3_bucket}"
echo "KMS key id : ${kms_key_id}"
echo "*** Add those values to your backend block"
