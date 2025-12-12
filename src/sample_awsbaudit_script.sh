#!/bin/bash
# Simple AWS Environment Audit Script

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI not found. Please install and configure AWS CLI first."
    exit 1
fi

echo "===== AWS Environment Audit ====="
echo "Date: $(date)"
echo "================================"

# Get current AWS account information
echo "Account & Identity Info:"
aws sts get-caller-identity
echo "--------------------------------"

# List available AWS regions
echo "Available AWS Regions:"
aws ec2 describe-regions --query "Regions[].RegionName" --output table
echo "--------------------------------"

# Loop through regions to list EC2 instances and security groups
for region in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text); do
    echo "Region: $region"
    
    # List EC2 Instances
    echo "EC2 Instances:"
    aws ec2 describe-instances --region $region --query "Reservations[].Instances[].{ID:InstanceId,Type:InstanceType,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table
    
    # List Security Groups
    echo "Security Groups:"
    aws ec2 describe-security-groups --region $region --query "SecurityGroups[].{Name:GroupName,ID:GroupId,Inbound:IpPermissions,Outbound:IpPermissionsEgress}" --output table
    
    echo "--------------------------------"
done

# List S3 buckets
echo "S3 Buckets:"
aws s3api list-buckets --query "Buckets[].Name" --output table
echo "--------------------------------"

# List IAM users
echo "IAM Users:"
aws iam list-users --query "Users[].{UserName:UserName,ARN:Arn,Created:CreateDate}" --output table
echo "================================"
echo "Audit Completed."
