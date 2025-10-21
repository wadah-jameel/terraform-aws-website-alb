#!/bin/bash

# Script to update website files without redeploying infrastructure

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_DIR/terraform"
WEBSITE_DIR="$PROJECT_DIR/website"

echo "🔄 Updating website files..."

cd "$TERRAFORM_DIR"

# Get S3 bucket name from Terraform output
S3_BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null)

if [ -z "$S3_BUCKET" ]; then
    echo "❌ Could not get S3 bucket name. Has the infrastructure been deployed?"
    exit 1
fi

if [ ! -d "$WEBSITE_DIR" ]; then
    echo "❌ Website directory not found at $WEBSITE_DIR"
    exit 1
fi

echo "📦 Uploading files to S3 bucket: $S3_BUCKET"
aws s3 sync "$WEBSITE_DIR" "s3://$S3_BUCKET/" --delete

# Get ALB DNS name
ALB_DNS=$(terraform output -raw load_balancer_dns 2>/dev/null)

echo "✅ Website files updated successfully!"
echo "🌐 Your website is available at: http://$ALB_DNS"
