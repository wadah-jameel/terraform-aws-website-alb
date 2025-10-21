variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "static-website"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Instance type must be t3.micro, t3.small, or t3.medium."
  }
}



# Add these variables to your existing variables.tf

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (costs extra)"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}
