variable "environment" {
  description = "Environment type: dev or prod"
  type        = string
}

variable "instance_ami" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "instance_storage_size" {
  description = "Storage size for EC2 root volume"
  type        = number
}

variable "instance_storage_type" {
  description = "Storage type for EC2 root volume"
  type        = string
}
