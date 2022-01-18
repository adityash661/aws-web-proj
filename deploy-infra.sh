#!/bin/bash
mkdir -p ~/.github
echo "aws-web-proj" > ~/.github/aws-web-proj-repo
echo "{{adityash661}}" > ~/.github/aws-web-proj-owner
echo "{{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}}" > ~/.github/aws-web-proj-token

STACK_NAME=awsbootstrap 
REGION=us-east-2 
CLI_PROFILE=checkforaws
EC2_INSTANCE_TYPE=t2.micro

GH_ACCESS_TOKEN=$(cat ~/.github/aws-web-proj-access-token)
GH_OWNER=$(cat ~/.github/aws-web-proj-owner)
GH_REPO=$(cat ~/.github/aws-web-proj-repo)
GH_BRANCH=main

AWS_ACCOUNT_ID=`aws sts get-caller-identity --profile awsbootstrap --query "Account" --output text`
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

Echo $CODEPIPELINE_BUCKET

# Deploys static resources
echo "\n\n=========== Deploying setup.yml ==========="
aws cloudformation deploy --region $REGION --profile $CLI_PROFILE --stack-name $STACK_NAME-setup 
--template-file setup.yml --no-fail-on-empty-changeset --capabilities CAPABILITY_NAMED_IAM 
--parameter-overrides CodePipelineBucket=$CODEPIPELINE_BUCKET

# Deploy the CloudFormation template
echo -e "\n\n=========== Deploying main.yml ==========="
aws cloudformation deploy --region $REGION --profile $CLI_PROFILE --stack-name $STACK_NAME 
--template-file main.yml --no-fail-on-empty-changeset --capabilities CAPABILITY_NAMED_IAM 
--parameter-overrides EC2InstanceType=$EC2_INSTANCE_TYPE

if [ $? -eq 0 ]; then
  aws cloudformation list-exports --profile awsbootstrap --query "Exports[?Name=='InstanceEndpoint'].Value" 
fi