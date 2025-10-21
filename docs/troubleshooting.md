# Troubleshooting Guide

## Common Issues

### Issue: Terraform state lock
**Error:** `Error locking state`
**Solution:**
```bash
terraform force-unlock <LOCK_ID>
