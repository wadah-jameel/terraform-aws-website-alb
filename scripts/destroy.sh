#!/bin/bash

# Script to destroy all infrastructure

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_DIR/terraform"

echo "🗑️  Destroying infrastructure..."
echo "⚠️  This will delete ALL resources created by Terraform!"

read -p "Are you sure you want to destroy all infrastructure? (type 'yes' to confirm): " -r
if [ "$REPLY" != "yes" ]; then
    echo "❌ Destruction cancelled"
    exit 1
fi

cd "$TERRAFORM_DIR"

echo "🔧 Destroying resources..."
terraform destroy -auto-approve

echo "✅ Infrastructure destroyed successfully!"
