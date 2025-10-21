#!/bin/bash

# Deployment script for static website infrastructure

set -e

echo "🚀 Starting deployment..."

# Initialize Terraform
echo "📦 Initializing Terraform..."
cd terraform
terraform init

# Validate configuration
echo "✅ Validating configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Apply changes
echo "🔧 Applying changes..."
terraform apply tfplan

# Output important information
echo "📊 Deployment complete! Here are your resources:"
terraform output

echo "✨ Done!"
