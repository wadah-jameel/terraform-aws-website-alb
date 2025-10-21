#!/bin/bash

# Enhanced deployment script for static website infrastructure

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_DIR/terraform"
WEBSITE_DIR="$PROJECT_DIR/website"

echo "🚀 Starting deployment..."
echo "Project directory: $PROJECT_DIR"

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Initialize Terraform
echo "📦 Initializing Terraform..."
cd "$TERRAFORM_DIR"
terraform init

# Validate configuration
echo "✅ Validating configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
read -p "Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Apply changes
echo "🔧 Applying changes..."
terraform apply tfplan

# Get outputs
echo "📊 Deployment complete! Here are your resources:"
terraform output

# Get ALB DNS name
ALB_DNS=$(terraform output -raw load_balancer_dns 2>/dev/null || echo "")
if [ -n "$ALB_DNS" ]; then
    echo "🌐 Website will be available at: http://$ALB_DNS"
    echo "⏳ Note: It may take a few minutes for the instances to be healthy"
fi

# Get S3 bucket name
S3_BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
if [ -n "$S3_BUCKET" ]; then
    echo "📦 S3 bucket created: $S3_BUCKET"
    
    # Upload website files to S3
    echo "📁 Uploading website files to S3..."
    if [ -d "$WEBSITE_DIR" ]; then
        aws s3 sync "$WEBSITE_DIR" "s3://$S3_BUCKET/" --delete
        echo "✅ Website files uploaded to S3"
    else
        echo "⚠️  Website directory not found at $WEBSITE_DIR"
    fi
fi

echo "✨ Deployment completed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Wait 2-3 minutes for instances to become healthy"
echo "2. Visit your website at: http://$ALB_DNS"
echo "3. Check the Auto Scaling Group in AWS Console"
echo "4. Monitor CloudWatch metrics"
echo ""
echo "🔧 To update the website:"
echo "1. Modify files in the website/ directory"
echo "2. Run: aws s3 sync website/ s3://$S3_BUCKET/ --delete"
echo "3. Or re-run this deployment script"
